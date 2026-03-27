#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset

typeset -gr tool_root=${0:A:h:h}
typeset -gr perf_lib=$tool_root/tools/highlighting-perf-lib.zsh

source "$perf_lib" || exit 1

_profile_usage() {
  cat <<'EOF'
usage: tools/profile-highlighting.zsh [--highlighters main,brackets] [--scenario NAME | --input FILE] [--length N] [--iterations N] [--trace]

Run zprof for one highlighting scenario or input buffer.
EOF
}

_profile_die() {
  print -u2 -- "profile-highlighting: $1"
  exit "${2:-1}"
}

local highlighters_arg=main scenario= input_file=
integer length=64 iterations=1 trace_mode=0

while (( $# > 0 )); do
  case $1 in
    (--help|-h)
      _profile_usage
      exit 0
      ;;
    (--list-scenarios)
      zshh_perf_list_scenarios
      exit 0
      ;;
    (--highlighters)
      shift
      (( $# > 0 )) || _profile_die '--highlighters requires a value' 2
      highlighters_arg=$1
      ;;
    (--highlighters=*)
      highlighters_arg=${1#--highlighters=}
      ;;
    (--scenario)
      shift
      (( $# > 0 )) || _profile_die '--scenario requires a value' 2
      scenario=$1
      ;;
    (--scenario=*)
      scenario=${1#--scenario=}
      ;;
    (--input)
      shift
      (( $# > 0 )) || _profile_die '--input requires a value' 2
      input_file=$1
      ;;
    (--input=*)
      input_file=${1#--input=}
      ;;
    (--length)
      shift
      (( $# > 0 )) || _profile_die '--length requires a value' 2
      length=$1
      ;;
    (--length=*)
      length=${1#--length=}
      ;;
    (--iterations)
      shift
      (( $# > 0 )) || _profile_die '--iterations requires a value' 2
      iterations=$1
      ;;
    (--iterations=*)
      iterations=${1#--iterations=}
      ;;
    (--trace)
      trace_mode=1
      ;;
    (-*)
      _profile_die "unknown option: $1" 2
      ;;
    (*)
      _profile_die "unexpected argument: $1" 2
      ;;
  esac
  shift
done

[[ -n $scenario || -n $input_file ]] || _profile_die 'either --scenario or --input is required' 2
[[ -z $scenario || -z $input_file ]] || _profile_die 'use either --scenario or --input, not both' 2
(( length > 0 )) || _profile_die '--length must be positive' 2
(( iterations > 0 )) || _profile_die '--iterations must be positive' 2

local -a highlighters=("${(@s:,:)highlighters_arg}")
highlighters=("${(@)highlighters:#}")
(( $#highlighters > 0 )) || _profile_die 'no highlighters selected' 2

if (( trace_mode )); then
  export ZSH_HIGHLIGHT_PERF_TRACE=1
else
  unset ZSH_HIGHLIGHT_PERF_TRACE
fi

zshh_perf_setup_runtime "$tool_root" || exit 1

local buffer_label
if [[ -n $scenario ]]; then
  zshh_perf_generate_scenario "$scenario" "$length" || exit 1
  buffer_label=$scenario
else
  zshh_perf_load_input "$input_file" || exit 1
  buffer_label=$input_file
fi

local buffer=$REPLY

zmodload zsh/zprof || _profile_die 'failed to load zsh/zprof'
zprof -c

integer run
for (( run = 1; run <= iterations; ++run )); do
  zshh_perf_run_highlight "$buffer" "${highlighters[@]}"
done

print -r -- "highlighters=${(j:,:)highlighters}"
print -r -- "buffer_label=$buffer_label"
print -r -- "buffer_bytes=$#buffer"
print -r -- "iterations=$iterations"
print
zprof

if (( trace_mode )); then
  print
  print -r -- $'trace\tkey\tvalue'
  zshh_perf_dump_trace_tsv 'trace'
fi
