#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset warn_create_global

typeset -gr repo_root=${0:A:h:h}
typeset -gr profile_tool=$repo_root/tools/profile-highlighting.zsh
typeset -gr benchmark_tool=$repo_root/tools/benchmark-highlighting.zsh
typeset -gr zprof_tool=$repo_root/tests/test-zprof.zsh
typeset -gr test_shell=${${${(z)$(ps -p $$ -o command=)}[1]#-}:-${commands[zsh]:-zsh}}

source "$repo_root/tools/highlighting-perf-lib.zsh" || {
  print -r -- '1..1'
  print -r -- 'not ok 1 - source perf library'
  exit 1
}

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

_assert_not_contains() {
  local description=$1 haystack=$2 needle=$3
  if [[ $haystack == *"$needle"* ]]; then
    _not_ok "$description" "unexpected ${(qqq)needle} in ${(qqq)haystack}"
  else
    _ok "$description"
  fi
}

_assert_grep() {
  local description=$1 haystack=$2 pattern=$3
  if print -r -- "$haystack" | grep -Eq -- "$pattern"; then
    _ok "$description"
  else
    _not_ok "$description" "missing pattern ${(qqq)pattern}"
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

if "$test_shell" -f "$profile_tool" --list-scenarios >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'profile tool lists long pipeline scenario' "$output" 'long-pipeline'
  _assert_contains 'profile tool lists bracket mix scenario' "$output" 'bracket-mix'
  _assert_contains 'profile tool lists option nested shell scenario' "$output" 'option-nested-shell-code'
  _assert_contains 'profile tool lists bracket cursor replay scenario' "$output" 'bracket-cursor-replay'
else
  _not_ok 'profile tool lists scenarios' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$benchmark_tool" --highlighters main --scenario long-pipeline --lengths 4 --runs 1 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'benchmark tool prints tabular header' "$output" $'highlighters\tscenario\tlength\trun\tbuffer_bytes\tseconds'
  _assert_contains 'benchmark tool prints a main scenario row' "$output" $'main\tlong-pipeline\t4\t1'
  _assert_contains 'benchmark tool prints trace rows' "$output" $'trace\tmain\tlong-pipeline\t4\t1'
else
  _not_ok 'benchmark tool runs a traced scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$benchmark_tool" --highlighters main --input "$input_file" --runs 1 >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  integer input_rows=${#${(M)${(@f)output}:#main$'\t'*}}
  _assert_eq 'benchmark tool emits one row for fixed input files' "$input_rows" '1'
  _assert_contains 'benchmark tool labels fixed input rows with the actual input path' "$output" $'main\t'"$input_file"$'\t'
else
  _not_ok 'benchmark tool handles fixed input mode' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$benchmark_tool" --highlighters main --scenario option-nested-shell-code --lengths 2 --runs 1 >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'benchmark tool prints an option nested shell scenario row' "$output" $'main\toption-nested-shell-code\t2\t1'
else
  _not_ok 'benchmark tool runs the option nested shell scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$benchmark_tool" --highlighters brackets --scenario bracket-cursor-replay --lengths 4 --runs 1 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'benchmark tool prints a bracket cursor replay row' "$output" $'brackets\tbracket-cursor-replay\t4\t1'
  _assert_contains 'cursor replay trace records cache reuse' "$output" $'trace\tbrackets\tbracket-cursor-replay\t4\t1\tbrackets.cache_reuse_hits\t1'
  _assert_contains 'cursor replay trace records cursor movement' "$output" $'trace\tbrackets\tbracket-cursor-replay\t4\t1\tdriver.cursor_moved_hits\t1'
else
  _not_ok 'benchmark tool runs the bracket cursor replay scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$benchmark_tool" --highlighters maim --scenario long-pipeline --lengths 1 --runs 1 >| "$stdout_file" 2>| "$stderr_file"; then
  _not_ok 'benchmark tool rejects unknown highlighters' 'unexpected success'
else
  errors=$(<"$stderr_file")
  _assert_contains 'benchmark tool rejects unknown highlighters' "$errors" 'highlighting-perf: unknown highlighter: maim'
fi

if "$test_shell" -f "$zprof_tool" brackets >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'zprof harness profiles brackets paint' "$output" '_zsh_highlight_highlighter_brackets_paint'
else
  _not_ok 'zprof harness profiles requested highlighter' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$profile_tool" --highlighters main --scenario long-pipeline --length 2 --iterations 2 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_contains 'profile tool accumulates trace counters across iterations' "$output" $'trace\tdriver.invocations\t2'
else
  _not_ok 'profile tool accumulates trace counters across iterations' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$profile_tool" --highlighters brackets --scenario bracket-cursor-replay --length 4 --iterations 2 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_not_contains 'profile tool omits structural full scans from replay-only traces' "$output" $'trace\tbrackets.full_scan_calls\t'
  _assert_contains 'profile tool traces cursor replay cache reuse' "$output" $'trace\tbrackets.cache_reuse_hits\t2'
  _assert_grep 'profile tool keeps zprof samples across replay iterations' "$output" '^[[:space:]]*[0-9]+\)[[:space:]]+2[[:space:]]+.*zshh_perf_run_highlight_cursor_replay$'
else
  _not_ok 'profile tool runs the bracket cursor replay scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

if "$test_shell" -f "$profile_tool" --highlighters brackets --scenario bracket-cursor-replay --length 4 --iterations 1 --trace >| "$stdout_file" 2>| "$stderr_file"; then
  output=$(<"$stdout_file")
  _assert_not_contains 'single replay profile omits buffer-modified hits after priming' "$output" $'trace\tbrackets.predicate_buffer_modified_hits\t'
  _assert_contains 'single replay profile records a cursor-only hit after priming' "$output" $'trace\tbrackets.predicate_cursor_only_hits\t1'
else
  _not_ok 'profile tool runs the single-iteration bracket cursor replay scenario' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

(
  builtin cd -q -- "$repo_root/tests" || exit 1
  if "$test_shell" -f ./test-zprof.zsh brackets >| "$stdout_file" 2>| "$stderr_file"; then
    output=$(<"$stdout_file")
    _assert_contains 'zprof harness resolves repo paths from script location' "$output" '_zsh_highlight_highlighter_brackets_paint'
  else
    _not_ok 'zprof harness resolves repo paths from script location' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
  fi
)

BUFFER=''
zshh_perf_force_repaint "$BUFFER"
if [[ $_ZSH_HIGHLIGHT_PRIOR_BUFFER != $BUFFER ]]; then
  _ok 'force repaint keeps empty buffers distinguishable'
else
  _not_ok 'force repaint keeps empty buffers distinguishable' 'prior buffer matched the empty test buffer'
fi

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
_assert_eq 'driver avoids region_highlight copy churn' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[driver.region_highlight_copy_calls]-0}" '0'
_assert_eq 'main trace removes args shift churn' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.args_shift_ops]-0}" '0'
_assert_eq 'main trace removes proc_buf rewrite churn' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.proc_buf_rewrites]-0}" '0'
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.highlight_list_calls]-0} > 0 )); then
  _ok 'main trace records highlight_list calls'
else
  _not_ok 'main trace records highlight_list calls' 'counter not incremented'
fi
_assert_eq 'main trace removes copied-tail recursion' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.nested_tail_copy_calls]-0}" '0'
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[main.nested_slice_calls]-0} > 0 )); then
  _ok 'main trace records bounded nested slices'
else
  _not_ok 'main trace records bounded nested slices' 'counter not incremented'
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
_assert_eq 'brackets trace avoids a second full scan on cursor-only repaint' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}" '1'
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0} > 0 )); then
  _ok 'brackets trace records cache reuse on cursor-only repaint'
else
  _not_ok 'brackets trace records cache reuse on cursor-only repaint' 'counter not incremented'
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.paint_calls]-0} == 2 )); then
  _ok 'brackets trace records repeated paint calls'
else
  _not_ok 'brackets trace records repeated paint calls' "expected 2, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.paint_calls]-0}"
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.rendered_region_builds]-0} > 0 )); then
  _ok 'brackets trace records rendered region builds on a structural scan'
else
  _not_ok 'brackets trace records rendered region builds on a structural scan' 'counter not incremented'
fi

BUFFER='([{}]) ([{}])'
CURSOR=0
region_highlight=()
zshh_perf_find_cursor_replay_positions "$BUFFER"
integer replay_prime_cursor=${REPLY%%:*}
integer replay_cursor=${REPLY#*:}
_zsh_highlight_perf_reset
zshh_perf_prime_highlight_cursor_replay "$BUFFER" brackets
_assert_eq 'cursor replay prime performs one structural full scan' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}" '1'
_assert_eq 'cursor replay prime does not claim cache reuse' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}" '0'
_assert_eq 'cursor replay prime records one cursor movement' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[driver.cursor_moved_hits]-0}" '1'
zshh_perf_run_highlight_cursor_replay "$BUFFER" "$replay_cursor" "$replay_prime_cursor" brackets
_assert_eq 'cursor replay helper skips a structural full scan on the replay paint' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}" '0'
_assert_eq 'cursor replay helper records one cache reuse' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}" '1'
_assert_eq 'cursor replay helper records cursor movement' "${_ZSH_HIGHLIGHT_PERF_COUNTERS[driver.cursor_moved_hits]-0}" '1'

BUFFER='echo (food)'
CURSOR=4
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.predicate_buffer_modified_hits]-0} > 0 )); then
  _ok 'brackets trace records edits separately from cursor-only motion'
else
  _not_ok 'brackets trace records edits separately from cursor-only motion' 'buffer-modified counter not incremented'
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.predicate_cursor_only_hits]-0} == 0 )); then
  _ok 'brackets trace keeps edit events out of cursor-only hits'
else
  _not_ok 'brackets trace keeps edit events out of cursor-only hits' "expected 0, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.predicate_cursor_only_hits]-0}"
fi

histchars='!^#'
BUFFER='print (foo)'
CURSOR=2
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
histchars='%^#'
CURSOR=3
region_highlight=()
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0} == 0 )); then
  _ok 'brackets cache invalidates on histchars changes'
else
  _not_ok 'brackets cache invalidates on histchars changes' "expected 0 cache reuses, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}"
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0} == 2 )); then
  _ok 'brackets reruns a full scan after histchars changes'
else
  _not_ok 'brackets reruns a full scan after histchars changes' "expected 2 full scans, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}"
fi
histchars='!^#'

typeset -g saved_bracket_level_1_style=${ZSH_HIGHLIGHT_STYLES[bracket-level-1]}
BUFFER='print (foo)'
CURSOR=2
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=red,bold'
CURSOR=3
region_highlight=()
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0} == 0 )); then
  _ok 'brackets cache invalidates on bracket-level style changes'
else
  _not_ok 'brackets cache invalidates on bracket-level style changes' "expected 0 cache reuses, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}"
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0} == 2 )); then
  _ok 'brackets reruns a full scan after bracket-level style changes'
else
  _not_ok 'brackets reruns a full scan after bracket-level style changes' "expected 2 full scans, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}"
fi
_assert_contains 'brackets replay picks up updated bracket-level styles' "${(j:$'\n':)region_highlight}" 'fg=red,bold'
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=$saved_bracket_level_1_style

typeset -g saved_bracket_error_style=${ZSH_HIGHLIGHT_STYLES[bracket-error]}
BUFFER='print )'
CURSOR=2
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=blue,bold'
CURSOR=3
region_highlight=()
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0} == 0 )); then
  _ok 'brackets cache invalidates on bracket-error style changes'
else
  _not_ok 'brackets cache invalidates on bracket-error style changes' "expected 0 cache reuses, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}"
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0} == 2 )); then
  _ok 'brackets reruns a full scan after bracket-error style changes'
else
  _not_ok 'brackets reruns a full scan after bracket-error style changes' "expected 2 full scans, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}"
fi
_assert_contains 'brackets replay picks up updated bracket-error styles' "${(j:$'\n':)region_highlight}" 'fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[bracket-error]=$saved_bracket_error_style

unsetopt rcquotes
BUFFER=$'print \'a\'\'b\''
CURSOR=3
region_highlight=()
_zsh_highlight_perf_reset
true && _zsh_highlight
setopt rcquotes
CURSOR=4
region_highlight=()
true && _zsh_highlight
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0} == 0 )); then
  _ok 'brackets cache invalidates on rcquotes changes'
else
  _not_ok 'brackets cache invalidates on rcquotes changes' "expected 0 cache reuses, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.cache_reuse_hits]-0}"
fi
if (( ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0} == 2 )); then
  _ok 'brackets reruns a full scan after rcquotes changes'
else
  _not_ok 'brackets reruns a full scan after rcquotes changes' "expected 2 full scans, got ${_ZSH_HIGHLIGHT_PERF_COUNTERS[brackets.full_scan_calls]-0}"
fi
unsetopt rcquotes

print -r -- "1..$test_count"
exit "$failure_count"
