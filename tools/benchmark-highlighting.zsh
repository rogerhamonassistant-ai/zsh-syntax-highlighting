#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset

typeset -gr tool_root=${0:A:h:h}
typeset -gr perf_lib=$tool_root/tools/highlighting-perf-lib.zsh

source "$perf_lib" || exit 1
zmodload zsh/datetime || {
  print -u2 -- 'benchmark-highlighting: failed to load zsh/datetime'
  exit 1
}

_benchmark_usage() {
  cat <<'EOF'
usage: tools/benchmark-highlighting.zsh [--highlighters main,brackets] [--scenario NAME | --input FILE] [--lengths 128,256,512] [--runs N] [--trace]

Benchmark highlighting over one input file or one generated scenario across one or more lengths.
EOF
}

_benchmark_die() {
  print -u2 -- "benchmark-highlighting: $1"
  exit "${2:-1}"
}

local highlighters_arg=main scenario= input_file= lengths_arg='128,256,512,1024' input_label=
integer runs=3 trace_mode=0

while (( $# > 0 )); do
  case $1 in
    (--help|-h)
      _benchmark_usage
      exit 0
      ;;
    (--list-scenarios)
      zshh_perf_list_scenarios
      exit 0
      ;;
    (--highlighters)
      shift
      (( $# > 0 )) || _benchmark_die '--highlighters requires a value' 2
      highlighters_arg=$1
      ;;
    (--highlighters=*)
      highlighters_arg=${1#--highlighters=}
      ;;
    (--scenario)
      shift
      (( $# > 0 )) || _benchmark_die '--scenario requires a value' 2
      scenario=$1
      ;;
    (--scenario=*)
      scenario=${1#--scenario=}
      ;;
    (--input)
      shift
      (( $# > 0 )) || _benchmark_die '--input requires a value' 2
      input_file=$1
      ;;
    (--input=*)
      input_file=${1#--input=}
      ;;
    (--lengths)
      shift
      (( $# > 0 )) || _benchmark_die '--lengths requires a value' 2
      lengths_arg=$1
      ;;
    (--lengths=*)
      lengths_arg=${1#--lengths=}
      ;;
    (--runs)
      shift
      (( $# > 0 )) || _benchmark_die '--runs requires a value' 2
      runs=$1
      ;;
    (--runs=*)
      runs=${1#--runs=}
      ;;
    (--trace)
      trace_mode=1
      ;;
    (-*)
      _benchmark_die "unknown option: $1" 2
      ;;
    (*)
      _benchmark_die "unexpected argument: $1" 2
      ;;
  esac
  shift
done

[[ -n $scenario || -n $input_file ]] || _benchmark_die 'either --scenario or --input is required' 2
[[ -z $scenario || -z $input_file ]] || _benchmark_die 'use either --scenario or --input, not both' 2
(( runs > 0 )) || _benchmark_die '--runs must be positive' 2

local -a highlighters=("${(@s:,:)highlighters_arg}")
local -a lengths=("${(@s:,:)lengths_arg}")
highlighters=("${(@)highlighters:#}")
lengths=("${(@)lengths:#}")
(( $#highlighters > 0 )) || _benchmark_die 'no highlighters selected' 2
(( $#lengths > 0 )) || _benchmark_die 'no lengths selected' 2

integer length
for length in "${lengths[@]}"; do
  (( length > 0 )) || _benchmark_die "invalid length: $length" 2
done

if (( trace_mode )); then
  export ZSH_HIGHLIGHT_PERF_TRACE=1
else
  unset ZSH_HIGHLIGHT_PERF_TRACE
fi

zshh_perf_setup_runtime "$tool_root" || exit 1
zshh_perf_validate_highlighters "$tool_root" "${highlighters[@]}" || exit 1

local fixed_input=
if [[ -n $input_file ]]; then
  zshh_perf_load_input "$input_file" || exit 1
  fixed_input=$REPLY
  input_label=$input_file
fi

print -r -- $'highlighters\tscenario\tlength\trun\tbuffer_bytes\tseconds'

integer run
local buffer scenario_label scenario_mode=single
local -a benchmark_lengths
local -F start_time end_time elapsed
integer replay_cursor
if [[ -n $scenario ]]; then
  benchmark_lengths=("${lengths[@]}")
else
  benchmark_lengths=($#fixed_input)
fi

for length in "${benchmark_lengths[@]}"; do
  if [[ -n $scenario ]]; then
    zshh_perf_generate_scenario "$scenario" "$length" || exit 1
    buffer=$REPLY
    scenario_label=$scenario
    zshh_perf_scenario_run_mode "$scenario"
    scenario_mode=$REPLY
  else
    buffer=$fixed_input
    scenario_label=$input_label
    scenario_mode=single
  fi

  for (( run = 1; run <= runs; ++run )); do
    if [[ $scenario_mode == cursor-replay ]]; then
      zshh_perf_prime_highlight_cursor_replay "$buffer" "${highlighters[@]}" || exit 1
      replay_cursor=$REPLY
      start_time=$EPOCHREALTIME
      zshh_perf_run_highlight_cursor_replay "$buffer" "$replay_cursor" "${highlighters[@]}"
    else
      start_time=$EPOCHREALTIME
      zshh_perf_run_highlight "$buffer" "${highlighters[@]}"
    fi
    end_time=$EPOCHREALTIME
    elapsed=$(( end_time - start_time ))

    print -r -- "${(j:,:)highlighters}"$'\t'"$scenario_label"$'\t'"$length"$'\t'"$run"$'\t'"$#buffer"$'\t'"$elapsed"

    if (( trace_mode )); then
      zshh_perf_dump_trace_tsv $'trace\t'"${(j:,:)highlighters}"$'\t'"$scenario_label"$'\t'"$length"$'\t'"$run"
    fi
  done
done
