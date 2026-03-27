#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset warn_create_global

typeset -gr repo_root=${0:A:h:h}
typeset -gr profile_tool=$repo_root/tools/profile-highlighting.zsh
typeset -gr benchmark_tool=$repo_root/tools/benchmark-highlighting.zsh
typeset -gr zprof_tool=$repo_root/tests/test-zprof.zsh

integer test_count=0 failure_count=0
typeset -g REPLY=''

_ok() {
  local description=$1
  (( ++test_count ))
  print -r -- "ok $test_count - $description"
}

_not_ok() {
  local description=$1 detail=${2-}
  (( ++test_count ))
  (( ++failure_count ))
  print -r -- "not ok $test_count - $description"
  [[ -n $detail ]] && print -r -- "# $detail"
}

_assert_contains() {
  local description=$1 haystack=$2 needle=$3
  if [[ $haystack == *"$needle"* ]]; then
    _ok "$description"
  else
    _not_ok "$description" "missing ${(qqq)needle} in ${(qqq)haystack}"
  fi
}

_assert_eq() {
  local description=$1 actual=$2 expected=$3
  if [[ $actual == $expected ]]; then
    _ok "$description"
  else
    _not_ok "$description" "expected ${(qqq)expected}, got ${(qqq)actual}"
  fi
}

typeset -gr temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zshh-perf-tools-test.XXXXXXXX") ||
  { print -u2 -- 'failed to create temp dir'; exit 1; }
trap 'rm -rf -- "$temp_dir"' EXIT

typeset -gr stdout_file=$temp_dir/stdout.txt
typeset -gr stderr_file=$temp_dir/stderr.txt
typeset -gr input_file=$temp_dir/input.zsh
typeset -g output='' errors=''
integer exit_code=0

print -r -- 'echo sample' >| "$input_file"

if zsh "$profile_tool" --list-scenarios >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'profile tool lists long pipeline scenario' "$output" 'long-pipeline'
  _assert_contains 'profile tool lists bracket mix scenario' "$output" 'bracket-mix'
else
  _not_ok 'profile tool lists scenarios' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if zsh "$benchmark_tool" --highlighters main --scenario long-pipeline --lengths 4 --runs 1 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'benchmark tool prints tabular header' "$output" $'highlighters\tscenario\tlength\trun\tbuffer_bytes\tseconds'
  _assert_contains 'benchmark tool prints a main scenario row' "$output" $'main\tlong-pipeline\t4\t1'
  _assert_contains 'benchmark tool prints trace rows' "$output" $'trace\tmain\tlong-pipeline\t4\t1'
else
  _not_ok 'benchmark tool runs a traced scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if zsh "$benchmark_tool" --highlighters main --input "$input_file" --runs 1 >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  integer input_rows=${#${(M)${(@f)output}:#main$'\t'*}}
  _assert_eq 'benchmark tool emits one row for fixed input files' "$input_rows" '1'
  _assert_contains 'benchmark tool labels fixed input rows with the actual input path' "$output" $'main\t'"$input_file"$'\t'
else
  _not_ok 'benchmark tool handles fixed input mode' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if zsh "$zprof_tool" brackets >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'zprof harness profiles brackets paint' "$output" '_zsh_highlight_highlighter_brackets_paint'
else
  _not_ok 'zprof harness profiles requested highlighter' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

(
  builtin cd -q -- "$repo_root/tests" || exit 1
  if zsh -f ./test-zprof.zsh brackets >| "$stdout_file" 2>| "$stderr_file"; then
    output=$(<"$stdout_file")
    _assert_contains 'zprof harness resolves repo paths from script location' "$output" '_zsh_highlight_highlighter_brackets_paint'
  else
    _not_ok 'zprof harness resolves repo paths from script location' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
  fi
)

typeset -ga region_highlight
export ZSH_HIGHLIGHT_PERF_TRACE=1
source "$repo_root/zsh-syntax-highlighting.zsh" || {
  print -r -- '1..1'
  print -r -- 'not ok 1 - source zsh-syntax-highlighting for perf tracing'
  exit 1
}

PREBUFFER=''
MARK=0
PENDING=0
REGION_ACTIVE=0
WIDGET=z-sy-h-test-harness-test-widget

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)
BUFFER='echo "$(print one)"'
CURSOR=$#BUFFER
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
_assert_eq 'main trace counts one driver invocation' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[driver.invocations]-0}" '1'
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.highlight_list_calls]-0} > 0 )); then
  _ok 'main trace records highlight_list calls'
else
  _not_ok 'main trace records highlight_list calls' 'counter not incremented'
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.nested_tail_copy_calls]-0} > 0 )); then
  _ok 'main trace records copied-tail recursion'
else
  _not_ok 'main trace records copied-tail recursion' 'counter not incremented'
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=(brackets)
BUFFER='echo (foo)'
CURSOR=2
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
CURSOR=3
region_highlight=()
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[driver.cursor_moved_hits]-0} > 0 )); then
  _ok 'brackets trace records cursor movement'
else
  _not_ok 'brackets trace records cursor movement' 'counter not incremented'
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.paint_calls]-0} == 2 )); then
  _ok 'brackets trace records repeated paint calls'
else
  _not_ok 'brackets trace records repeated paint calls' "expected 2, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.paint_calls]-0}"
fi

print -r -- "1..$test_count"
exit "$failure_count"
