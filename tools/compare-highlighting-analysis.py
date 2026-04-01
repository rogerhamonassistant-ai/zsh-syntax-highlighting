#!/usr/bin/env python3

from __future__ import annotations

import argparse
import csv
import hashlib
import math
import random
import statistics
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class SummaryRow:
    label: str
    highlighters: str
    scenario: str
    length: int
    run: int
    baseline_before_seconds: float
    candidate_seconds: float
    baseline_after_seconds: float
    bracketed_baseline_mean_seconds: float
    delta_percent: float
    baseline_drift_percent: float

    @property
    def baseline_halfspan_percent(self) -> float:
        if self.bracketed_baseline_mean_seconds <= 0.0:
            return 0.0
        return (
            abs(self.baseline_after_seconds - self.baseline_before_seconds)
            / self.bracketed_baseline_mean_seconds
            * 100.0
        )

    @property
    def abs_baseline_drift_percent(self) -> float:
        return abs(self.baseline_drift_percent)


@dataclass(frozen=True)
class GroupSummary:
    label: str
    highlighters: str
    scenario: str
    length: int
    runs: int
    kept_runs: int
    pruned_runs: int
    delta_median_percent: float
    delta_mean_percent: float
    delta_ci95_low_percent: float
    delta_ci95_high_percent: float
    median_baseline_halfspan_percent: float
    max_baseline_halfspan_percent: float
    median_abs_baseline_drift_percent: float
    max_abs_baseline_drift_percent: float
    outside_bracket_runs: int
    faster_outside_bracket_runs: int
    slower_outside_bracket_runs: int
    verdict: str
    confidence: str
    prune_reasons: str


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Aggregate compare-highlighting.zsh logs and summarize multi-run "
            "results with robust delta estimates and confidence brackets."
        )
    )
    parser.add_argument(
        "files",
        nargs="+",
        help="TSV files produced by tools/compare-highlighting.zsh",
    )
    parser.add_argument(
        "--bootstrap-samples",
        type=int,
        default=5000,
        help="bootstrap samples for the median delta CI (default: %(default)s)",
    )
    parser.add_argument(
        "--mad-z-threshold",
        type=float,
        default=3.5,
        help="robust z-score threshold for delta/halfspan outlier pruning (default: %(default)s)",
    )
    parser.add_argument(
        "--max-halfspan-pct",
        type=float,
        default=None,
        help="optional hard cap for baseline halfspan pruning",
    )
    parser.add_argument(
        "--min-kept-runs",
        type=int,
        default=3,
        help="minimum kept runs for anything stronger than low confidence (default: %(default)s)",
    )
    parser.add_argument(
        "--no-prune",
        action="store_true",
        help="disable outlier pruning and analyze all runs as-is",
    )
    return parser.parse_args()


def _die(message: str) -> "NoReturn":
    print(f"compare-highlighting-analysis: {message}", file=sys.stderr)
    raise SystemExit(1)


def _load_rows(paths: Iterable[Path]) -> list[SummaryRow]:
    rows: list[SummaryRow] = []
    for path in paths:
        with path.open(newline="") as handle:
            for raw_line in handle:
                line = raw_line.rstrip("\n")
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t")
                if not parts or parts[0] != "summary":
                    continue
                if len(parts) != 12:
                    _die(f"{path}: malformed summary row with {len(parts)} fields")
                rows.append(
                    SummaryRow(
                        label=parts[1],
                        highlighters=parts[2],
                        scenario=parts[3],
                        length=int(parts[4]),
                        run=int(parts[5]),
                        baseline_before_seconds=float(parts[6]),
                        candidate_seconds=float(parts[7]),
                        baseline_after_seconds=float(parts[8]),
                        bracketed_baseline_mean_seconds=float(parts[9]),
                        delta_percent=float(parts[10]),
                        baseline_drift_percent=float(parts[11]),
                    )
                )
    if not rows:
        _die("no summary rows found in the provided input")
    return rows


def _median(values: list[float]) -> float:
    return statistics.median(values) if values else 0.0


def _mean(values: list[float]) -> float:
    return statistics.fmean(values) if values else 0.0


def _median_abs_deviation(values: list[float], center: float) -> float:
    return _median([abs(value - center) for value in values])


def _mad_outlier_mask(values: list[float], threshold: float, *, one_sided: bool = False) -> list[bool]:
    if len(values) < 4:
        return [False] * len(values)
    center = _median(values)
    mad = _median_abs_deviation(values, center)
    if mad <= 0.0:
        return [False] * len(values)
    scale = 1.4826 * mad
    mask: list[bool] = []
    for value in values:
        robust_z = (value - center) / scale
        if one_sided:
            mask.append(robust_z > threshold)
        else:
            mask.append(abs(robust_z) > threshold)
    return mask


def _bootstrap_median_ci(values: list[float], *, samples: int, confidence: float, seed_key: str) -> tuple[float, float]:
    if not values:
        return (0.0, 0.0)
    if len(values) == 1:
        return (values[0], values[0])
    seed_bytes = hashlib.sha256(seed_key.encode("utf-8")).digest()
    rng = random.Random(int.from_bytes(seed_bytes[:8], "big"))
    medians = []
    n = len(values)
    for _ in range(samples):
        sample = [values[rng.randrange(n)] for _ in range(n)]
        medians.append(statistics.median(sample))
    medians.sort()
    alpha = (1.0 - confidence) / 2.0
    low_index = max(0, min(len(medians) - 1, int(math.floor(alpha * len(medians)))))
    high_index = max(0, min(len(medians) - 1, int(math.ceil((1.0 - alpha) * len(medians))) - 1))
    return (medians[low_index], medians[high_index])


def _verdict(
    ci_low: float,
    ci_high: float,
    kept_runs: int,
    faster_outside_runs: int,
    slower_outside_runs: int,
) -> str:
    if kept_runs <= 0:
        return "unclear"
    faster_fraction = faster_outside_runs / kept_runs
    slower_fraction = slower_outside_runs / kept_runs
    if ci_high < 0.0 and faster_fraction >= 0.8:
        return "faster"
    if ci_low > 0.0 and slower_fraction >= 0.8:
        return "slower"
    return "unclear"


def _confidence_level(
    kept_runs: int,
    min_kept_runs: int,
    median_halfspan: float,
    max_halfspan: float,
    ci_low: float,
    ci_high: float,
) -> str:
    ci_width = ci_high - ci_low
    if kept_runs < min_kept_runs:
        return "low"
    if median_halfspan <= 2.0 and max_halfspan <= 5.0 and ci_width <= 3.0:
        return "high"
    if median_halfspan <= 5.0 and max_halfspan <= 15.0 and ci_width <= 8.0:
        return "medium"
    return "low"


def _summarize_group(
    key: tuple[str, str, str, int],
    rows: list[SummaryRow],
    *,
    prune: bool,
    mad_z_threshold: float,
    max_halfspan_pct: float | None,
    min_kept_runs: int,
    bootstrap_samples: int,
) -> GroupSummary:
    deltas = [row.delta_percent for row in rows]
    halfspans = [row.baseline_halfspan_percent for row in rows]

    delta_outliers = [False] * len(rows)
    halfspan_outliers = [False] * len(rows)
    hard_halfspan_outliers = [False] * len(rows)
    if prune:
        delta_outliers = _mad_outlier_mask(deltas, mad_z_threshold)
        halfspan_outliers = _mad_outlier_mask(halfspans, mad_z_threshold, one_sided=True)
        if max_halfspan_pct is not None:
            hard_halfspan_outliers = [halfspan > max_halfspan_pct for halfspan in halfspans]

    kept_rows = [
        row
        for row, is_delta_outlier, is_halfspan_outlier, is_hard_halfspan_outlier in zip(
            rows, delta_outliers, halfspan_outliers, hard_halfspan_outliers
        )
        if not (is_delta_outlier or is_halfspan_outlier or is_hard_halfspan_outlier)
    ]
    if not kept_rows:
        kept_rows = rows[:]
        delta_outliers = [False] * len(rows)
        halfspan_outliers = [False] * len(rows)
        hard_halfspan_outliers = [False] * len(rows)

    kept_deltas = [row.delta_percent for row in kept_rows]
    kept_halfspans = [row.baseline_halfspan_percent for row in kept_rows]
    kept_abs_drifts = [row.abs_baseline_drift_percent for row in kept_rows]
    outside_bracket_runs = 0
    faster_outside_runs = 0
    slower_outside_runs = 0
    for row in kept_rows:
        baseline_low = min(row.baseline_before_seconds, row.baseline_after_seconds)
        baseline_high = max(row.baseline_before_seconds, row.baseline_after_seconds)
        if row.candidate_seconds < baseline_low:
            outside_bracket_runs += 1
            faster_outside_runs += 1
        elif row.candidate_seconds > baseline_high:
            outside_bracket_runs += 1
            slower_outside_runs += 1

    key_string = "\t".join(map(str, key))
    ci_low, ci_high = _bootstrap_median_ci(
        kept_deltas,
        samples=bootstrap_samples,
        confidence=0.95,
        seed_key=key_string,
    )

    prune_counts = []
    if any(delta_outliers):
        prune_counts.append(f"delta:{sum(delta_outliers)}")
    if any(halfspan_outliers):
        prune_counts.append(f"halfspan:{sum(halfspan_outliers)}")
    if any(hard_halfspan_outliers):
        prune_counts.append(f"max-halfspan:{sum(hard_halfspan_outliers)}")
    prune_reasons = ",".join(prune_counts) if prune_counts else "-"

    median_halfspan = _median(kept_halfspans)
    max_halfspan = max(kept_halfspans) if kept_halfspans else 0.0

    return GroupSummary(
        label=key[0],
        highlighters=key[1],
        scenario=key[2],
        length=key[3],
        runs=len(rows),
        kept_runs=len(kept_rows),
        pruned_runs=len(rows) - len(kept_rows),
        delta_median_percent=_median(kept_deltas),
        delta_mean_percent=_mean(kept_deltas),
        delta_ci95_low_percent=ci_low,
        delta_ci95_high_percent=ci_high,
        median_baseline_halfspan_percent=median_halfspan,
        max_baseline_halfspan_percent=max_halfspan,
        median_abs_baseline_drift_percent=_median(kept_abs_drifts),
        max_abs_baseline_drift_percent=max(kept_abs_drifts) if kept_abs_drifts else 0.0,
        outside_bracket_runs=outside_bracket_runs,
        faster_outside_bracket_runs=faster_outside_runs,
        slower_outside_bracket_runs=slower_outside_runs,
        verdict=_verdict(ci_low, ci_high, len(kept_rows), faster_outside_runs, slower_outside_runs),
        confidence=_confidence_level(
            len(kept_rows),
            min_kept_runs,
            median_halfspan,
            max_halfspan,
            ci_low,
            ci_high,
        ),
        prune_reasons=prune_reasons,
    )


def main() -> int:
    args = _parse_args()
    paths = [Path(raw_path) for raw_path in args.files]
    missing = [str(path) for path in paths if not path.is_file()]
    if missing:
        _die(f"missing files: {', '.join(missing)}")

    rows = _load_rows(paths)
    groups: dict[tuple[str, str, str, int], list[SummaryRow]] = {}
    for row in rows:
        groups.setdefault((row.label, row.highlighters, row.scenario, row.length), []).append(row)

    summaries = [
        _summarize_group(
            key,
            groups[key],
            prune=not args.no_prune,
            mad_z_threshold=args.mad_z_threshold,
            max_halfspan_pct=args.max_halfspan_pct,
            min_kept_runs=args.min_kept_runs,
            bootstrap_samples=args.bootstrap_samples,
        )
        for key in sorted(groups.keys(), key=lambda item: (item[1], item[2], item[3], item[0]))
    ]

    writer = csv.writer(sys.stdout, delimiter="\t", lineterminator="\n")
    writer.writerow(
        [
            "label",
            "highlighters",
            "scenario",
            "length",
            "runs",
            "kept_runs",
            "pruned_runs",
            "delta_median_pct",
            "delta_mean_pct",
            "delta_ci95_low_pct",
            "delta_ci95_high_pct",
            "median_baseline_halfspan_pct",
            "max_baseline_halfspan_pct",
            "median_abs_baseline_drift_pct",
            "max_abs_baseline_drift_pct",
            "outside_bracket_runs",
            "faster_outside_bracket_runs",
            "slower_outside_bracket_runs",
            "verdict",
            "confidence",
            "prune_reasons",
        ]
    )
    for summary in summaries:
        writer.writerow(
            [
                summary.label,
                summary.highlighters,
                summary.scenario,
                summary.length,
                summary.runs,
                summary.kept_runs,
                summary.pruned_runs,
                f"{summary.delta_median_percent:.6f}",
                f"{summary.delta_mean_percent:.6f}",
                f"{summary.delta_ci95_low_percent:.6f}",
                f"{summary.delta_ci95_high_percent:.6f}",
                f"{summary.median_baseline_halfspan_percent:.6f}",
                f"{summary.max_baseline_halfspan_percent:.6f}",
                f"{summary.median_abs_baseline_drift_percent:.6f}",
                f"{summary.max_abs_baseline_drift_percent:.6f}",
                summary.outside_bracket_runs,
                summary.faster_outside_bracket_runs,
                summary.slower_outside_bracket_runs,
                summary.verdict,
                summary.confidence,
                summary.prune_reasons,
            ]
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
