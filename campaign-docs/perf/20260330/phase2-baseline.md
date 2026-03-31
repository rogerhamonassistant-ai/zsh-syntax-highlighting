# Phase 2 Baseline

Commit: `dc57963`

Machine-local measurements before the next perf PR train.

## Benchmarks

### `main`

| Scenario | Lengths | Seconds |
| --- | --- | --- |
| `long-pipeline` | `64 / 256 / 1024` | `1.11 / 4.67 / 27.30` |
| `long-double-quoted-cmdsubst` | `32 / 128 / 512` | `0.78 / 3.68 / 24.08` |

### `brackets`

| Scenario | Lengths | Seconds |
| --- | --- | --- |
| `bracket-mix` | `64 / 256 / 1024` | `6.24 / 14.55 / 166.62` |

## Trace Notes

- `main long-pipeline` still scales linearly in token counters but not in wall-clock time:
  - `64`: `main.highlight_list_token_iterations=191`
  - `256`: `main.highlight_list_token_iterations=767`
  - `1024`: `main.highlight_list_token_iterations=3071`
- `main long-double-quoted-cmdsubst` still re-enters nested highlighting once per nested substitution:
  - `32`: `main.highlight_list_calls=33`, `main.nested_slice_calls=32`
  - `128`: `main.highlight_list_calls=129`, `main.nested_slice_calls=128`
  - `512`: `main.highlight_list_calls=513`, `main.nested_slice_calls=512`

## Zprof Notes

- `brackets` is still dominated by `_zsh_highlight_highlighter_brackets_paint`.
- On the current zprof harness, the paint function accounts for essentially all runtime, with helper probes far behind it.
