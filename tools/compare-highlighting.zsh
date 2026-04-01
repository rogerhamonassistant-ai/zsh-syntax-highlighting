#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset

typeset -gr tool_root=${0:A:h:h}
typeset -gr benchmark_tool_name=tools/benchmark-highlighting.zsh
typeset -gr benchmark_tool_path=$tool_root/$benchmark_tool_name
typeset -gr tool_shell=${${${(z)$(ps -p $$ -o command=)}[1]#-}:-${commands[zsh]:-zsh}}

_compare_usage() {
  cat <<'EOF'
usage: tools/compare-highlighting.zsh --baseline DIR --candidate LABEL=DIR [--candidate LABEL=DIR ...] --scenario NAME [--scenario NAME ...] [--highlighters main,brackets] [--lengths 128,256] [--runs N] [--repeat N] [--rolling-baseline] [--trace]

Run bracketed baseline/candidate comparisons for highlighting benchmarks.

For each scenario, length, and run:
  1. baseline-before
  2. each candidate, repeated N times
  3. baseline-after

With `--rolling-baseline`, each run after the first reuses the prior
`baseline-after` as its bracket start within the same scenario/length block.

The script prints:
  - result rows prefixed with `result`
  - trace rows prefixed with `trace` when `--trace` is enabled
  - summary rows prefixed with `summary`
EOF
}

_compare_die() {
  print -u2 -- "compare-highlighting: $1"
  exit "${2:-1}"
}

typeset baseline_dir= highlighters_arg=main lengths_arg='128,256' trace_flag=
typeset -a candidate_labels=() candidate_dirs=() scenarios=()
integer runs=1 repeat_count=1 trace_mode=0 rolling_baseline=0

while (( $# > 0 )); do
  case $1 in
    (--help|-h)
      _compare_usage
      exit 0
      ;;
    (--baseline)
      shift
      (( $# > 0 )) || _compare_die '--baseline requires a value' 2
      baseline_dir=$1
      ;;
    (--baseline=*)
      baseline_dir=${1#--baseline=}
      ;;
    (--candidate)
      shift
      (( $# > 0 )) || _compare_die '--candidate requires a value' 2
      typeset candidate_spec=$1
      typeset candidate_label=${candidate_spec%%=*}
      typeset candidate_dir=${candidate_spec#*=}
      [[ $candidate_label != "$candidate_spec" && -n $candidate_label && -n $candidate_dir ]] || _compare_die '--candidate must be LABEL=DIR' 2
      candidate_labels+=("$candidate_label")
      candidate_dirs+=("$candidate_dir")
      ;;
    (--candidate=*)
      typeset candidate_spec=${1#--candidate=}
      typeset candidate_label=${candidate_spec%%=*}
      typeset candidate_dir=${candidate_spec#*=}
      [[ $candidate_label != "$candidate_spec" && -n $candidate_label && -n $candidate_dir ]] || _compare_die '--candidate must be LABEL=DIR' 2
      candidate_labels+=("$candidate_label")
      candidate_dirs+=("$candidate_dir")
      ;;
    (--highlighters)
      shift
      (( $# > 0 )) || _compare_die '--highlighters requires a value' 2
      highlighters_arg=$1
      ;;
    (--highlighters=*)
      highlighters_arg=${1#--highlighters=}
      ;;
    (--scenario)
      shift
      (( $# > 0 )) || _compare_die '--scenario requires a value' 2
      scenarios+=("${(@s:,:)1}")
      ;;
    (--scenario=*)
      scenarios+=("${(@s:,:)${1#--scenario=}}")
      ;;
    (--lengths)
      shift
      (( $# > 0 )) || _compare_die '--lengths requires a value' 2
      lengths_arg=$1
      ;;
    (--lengths=*)
      lengths_arg=${1#--lengths=}
      ;;
    (--runs)
      shift
      (( $# > 0 )) || _compare_die '--runs requires a value' 2
      runs=$1
      ;;
    (--runs=*)
      runs=${1#--runs=}
      ;;
    (--repeat)
      shift
      (( $# > 0 )) || _compare_die '--repeat requires a value' 2
      repeat_count=$1
      ;;
    (--repeat=*)
      repeat_count=${1#--repeat=}
      ;;
    (--rolling-baseline)
      rolling_baseline=1
      ;;
    (--trace)
      trace_mode=1
      trace_flag=--trace
      ;;
    (-*)
      _compare_die "unknown option: $1" 2
      ;;
    (*)
      _compare_die "unexpected argument: $1" 2
      ;;
  esac
  shift
done

[[ -n $baseline_dir ]] || _compare_die '--baseline is required' 2
(( $#candidate_labels > 0 )) || _compare_die 'at least one --candidate is required' 2
(( $#scenarios > 0 )) || _compare_die 'at least one --scenario is required' 2
(( runs > 0 )) || _compare_die '--runs must be positive' 2
(( repeat_count > 0 )) || _compare_die '--repeat must be positive' 2

typeset -a highlighters=("${(@s:,:)highlighters_arg}")
typeset -a lengths=("${(@s:,:)lengths_arg}")
highlighters=("${(@)highlighters:#}")
lengths=("${(@)lengths:#}")
scenarios=("${(@)scenarios:#}")
(( $#highlighters > 0 )) || _compare_die 'no highlighters selected' 2
(( $#lengths > 0 )) || _compare_die 'no lengths selected' 2

typeset candidate_label= candidate_dir=
integer idx length run
typeset scenario

[[ -x $benchmark_tool_path || -f $benchmark_tool_path ]] || _compare_die "benchmark tool not found: $benchmark_tool_path" 2
[[ -d $baseline_dir ]] || _compare_die "not a directory: $baseline_dir" 2
[[ -f $baseline_dir/$benchmark_tool_name ]] || _compare_die "baseline directory does not contain $benchmark_tool_name" 2

typeset -A seen_candidate_labels=()
for idx in {1..$#candidate_labels}; do
  candidate_label=$candidate_labels[$idx]
  candidate_dir=$candidate_dirs[$idx]
  [[ -d $candidate_dir ]] || _compare_die "not a directory: $candidate_dir" 2
  [[ -f $candidate_dir/$benchmark_tool_name ]] || _compare_die "candidate directory does not contain $benchmark_tool_name: $candidate_dir" 2
  (( ${+seen_candidate_labels[$candidate_label]} == 0 )) || _compare_die "duplicate candidate label: $candidate_label" 2
  seen_candidate_labels[$candidate_label]=1
done

integer length_value
for length in "${lengths[@]}"; do
  length_value=$length
  (( length_value > 0 )) || _compare_die "invalid length: $length" 2
done

typeset -gr temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zshh-compare-test.XXXXXXXX") ||
  _compare_die 'failed to create temp dir'
trap 'rm -rf -- "$temp_dir"' EXIT
typeset -gr stdout_file=$temp_dir/stdout.txt
typeset -gr stderr_file=$temp_dir/stderr.txt

print -r -- $'# result columns: kind\tphase\tlabel\thighlighters\tscenario\tlength\trun\trepeat\tbuffer_bytes\tseconds'
print -r -- $'# trace columns: kind\tphase\tlabel\thighlighters\tscenario\tlength\trun\trepeat\tmetric\tvalue'
print -r -- $'# summary columns: kind\tlabel\thighlighters\tscenario\tlength\trun\trepeat\tbaseline_before_seconds\tcandidate_seconds\tbaseline_after_seconds\tbracketed_baseline_mean_seconds\tdelta_percent\tbaseline_drift_percent'

_compare_emit_prefixed_output() {
  local phase=$1 label=$2 run_value=$3 repeat_value=$4
  local line
  local result_line=
  local -a parts

  while IFS= read -r line; do
    [[ -n $line ]] || continue
    [[ $line == highlighters$'\t'* ]] && continue
    if [[ $line == trace$'\t'* ]]; then
      parts=("${(@ps:\t:)${line#trace$'\t'}}")
      (( $#parts == 6 )) || _compare_die "malformed trace row for $label / $phase: $line"
      print -r -- "trace"$'\t'"$phase"$'\t'"$label"$'\t'"$parts[1]"$'\t'"$parts[2]"$'\t'"$parts[3]"$'\t'"$run_value"$'\t'"$repeat_value"$'\t'"$parts[5]"$'\t'"$parts[6]"
    else
      parts=("${(@ps:\t:)line}")
      (( $#parts == 6 )) || _compare_die "malformed result row for $label / $phase: $line"
      print -r -- "result"$'\t'"$phase"$'\t'"$label"$'\t'"$parts[1]"$'\t'"$parts[2]"$'\t'"$parts[3]"$'\t'"$run_value"$'\t'"$repeat_value"$'\t'"$parts[5]"$'\t'"$parts[6]"
      result_line=$line
    fi
  done < "$stdout_file"

  [[ -n $result_line ]] || _compare_die "no benchmark result row for $label / $phase"
  REPLY=$result_line
}

_compare_emit_prefixed_result_line() {
  local phase=$1 label=$2 run_value=$3 repeat_value=$4 result_line=$5
  local -a parts=("${(@ps:\t:)result_line}")
  (( $#parts == 6 )) || _compare_die "malformed result row for $label / $phase: $result_line"
  print -r -- "result"$'\t'"$phase"$'\t'"$label"$'\t'"$parts[1]"$'\t'"$parts[2]"$'\t'"$parts[3]"$'\t'"$run_value"$'\t'"$repeat_value"$'\t'"$parts[5]"$'\t'"$parts[6]"
}

_compare_run_once() {
  local phase=$1 label=$2 repo_dir=$3 scenario_name=$4 length_value=$5 run_value=$6 repeat_value=$7
  local -a cmd=("$tool_shell" -f "$repo_dir/$benchmark_tool_name" --highlighters "$highlighters_arg" --scenario "$scenario_name" --lengths "$length_value" --runs 1)
  (( trace_mode )) && cmd+=("$trace_flag")

  "${cmd[@]}" >| "$stdout_file" 2>| "$stderr_file" || _compare_die "benchmark failed for $label / $phase / $scenario_name / $length_value"$'\n'"$(<"$stderr_file")"
  _compare_emit_prefixed_output "$phase" "$label" "$run_value" "$repeat_value"
}

typeset baseline_before_line baseline_after_line candidate_line
typeset -a fields
typeset -F baseline_before_seconds baseline_after_seconds candidate_seconds baseline_mean_seconds delta_percent baseline_drift_percent
integer repeat
typeset carried_baseline_line=

for scenario in "${scenarios[@]}"; do
  carried_baseline_line=
  for length in "${lengths[@]}"; do
    carried_baseline_line=
    for (( run = 1; run <= runs; ++run )); do
      if (( rolling_baseline && run > 1 )); then
        [[ -n $carried_baseline_line ]] || _compare_die "missing carried baseline for $scenario / $length / run $run"
        baseline_before_line=$carried_baseline_line
        _compare_emit_prefixed_result_line baseline-before-rolling baseline "$run" 0 "$baseline_before_line"
      else
        _compare_run_once baseline-before baseline "$baseline_dir" "$scenario" "$length" "$run" 0
        baseline_before_line=$REPLY
      fi
      fields=("${(@ps:\t:)baseline_before_line}")
      baseline_before_seconds=${fields[6]}

      typeset -A candidate_seconds_by_label_repeat=()
      for (( repeat = 1; repeat <= repeat_count; ++repeat )); do
        for idx in {1..$#candidate_labels}; do
          candidate_label=$candidate_labels[$idx]
          candidate_dir=$candidate_dirs[$idx]
          _compare_run_once candidate "$candidate_label" "$candidate_dir" "$scenario" "$length" "$run" "$repeat"
          candidate_line=$REPLY
          fields=("${(@ps:\t:)candidate_line}")
          candidate_seconds_by_label_repeat[$candidate_label:$repeat]=${fields[6]}
        done
      done

      _compare_run_once baseline-after baseline "$baseline_dir" "$scenario" "$length" "$run" 0
      baseline_after_line=$REPLY
      carried_baseline_line=$baseline_after_line
      fields=("${(@ps:\t:)baseline_after_line}")
      baseline_after_seconds=${fields[6]}

      baseline_mean_seconds=$(( (baseline_before_seconds + baseline_after_seconds) / 2.0 ))
      if (( baseline_before_seconds > 0.0 )); then
        baseline_drift_percent=$(( ((baseline_after_seconds - baseline_before_seconds) / baseline_before_seconds) * 100.0 ))
      else
        baseline_drift_percent=0.0
      fi

      for (( repeat = 1; repeat <= repeat_count; ++repeat )); do
        for candidate_label in "${candidate_labels[@]}"; do
          candidate_seconds=${candidate_seconds_by_label_repeat[$candidate_label:$repeat]}
          if (( baseline_mean_seconds > 0.0 )); then
            delta_percent=$(( ((candidate_seconds - baseline_mean_seconds) / baseline_mean_seconds) * 100.0 ))
          else
            delta_percent=0.0
          fi
          print -r -- "summary"$'\t'"$candidate_label"$'\t'"${(j:,:)highlighters}"$'\t'"$scenario"$'\t'"$length"$'\t'"$run"$'\t'"$repeat"$'\t'"$baseline_before_seconds"$'\t'"$candidate_seconds"$'\t'"$baseline_after_seconds"$'\t'"$baseline_mean_seconds"$'\t'"$delta_percent"$'\t'"$baseline_drift_percent"
        done
      done
    done
  done
done
