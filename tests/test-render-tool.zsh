#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset warn_create_global

typeset -gr tool_root=${0:A:h:h}
typeset -gr tool_script=$tool_root/tools/render-with-zsh-syntax-highlighting.zsh

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

_assert_eq() {
  local description=$1 actual=$2 expected=$3
  if [[ $actual == $expected ]]; then
    _ok "$description"
  else
    _not_ok "$description" "expected ${(qqq)expected}, got ${(qqq)actual}"
  fi
}

_assert_contains() {
  local description=$1 haystack=$2 needle=$3
  if [[ $haystack == *"$needle"* ]]; then
    _ok "$description"
  else
    _not_ok "$description" "missing ${(qqq)needle} in ${(qqq)haystack}"
  fi
}

_assert_sgr() {
  local description=$1 spec=$2 expected=$3

  if ! _render_style_to_sgr "$spec"; then
    _not_ok "$description" 'parser returned failure'
    return
  fi

  _assert_eq "$description" "$REPLY" "$expected"
}

typeset -gr temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/zshh-render-tool-test.XXXXXXXX") ||
  { print -u2 -- 'failed to create temp dir'; exit 1; }
trap 'rm -rf -- "$temp_dir"' EXIT

typeset -gr sample_file=$temp_dir/sample.zsh
typeset -gr other_file=$temp_dir/other.zsh

print -r -- 'echo hello' >| "$sample_file"
print -r -- 'echo goodbye' >| "$other_file"

typeset -gr stdout_file=$temp_dir/stdout.txt
typeset -gr stderr_file=$temp_dir/stderr.txt
typeset -g rendered_output render_error
integer exit_code=0
integer render_exit=0

_run_render() {
  local input_file=$1
  shift
  local -a shell_opts=()

  while (( $# > 0 )); do
    shell_opts+=( -o "$1" )
    shift
  done

  rendered_output=''
  render_error=''
  if zsh "${shell_opts[@]}" "$tool_script" "$input_file" >| "$stdout_file" 2>| "$stderr_file"; then
    render_exit=0
  else
    render_exit=$?
  fi
  rendered_output=$(<"$stdout_file")
  render_error=$(<"$stderr_file")
}

if zsh "$tool_script" -- "$sample_file" >| "$stdout_file" 2>| "$stderr_file"; then
  rendered_output=$(<"$stdout_file")
  [[ $rendered_output == *$'\033['* ]] || _not_ok 'single operand after -- renders ANSI output' 'expected ANSI escape sequence in output'
  [[ $rendered_output == *$'echo'* ]] || _not_ok 'single operand after -- keeps file content in output' 'expected visible source text in render output'
  [[ $rendered_output == *$'\033['* && $rendered_output == *$'echo'* ]] && _ok 'single operand after -- renders the requested file'
else
  render_error=$(<"$stderr_file")
  _not_ok 'single operand after -- renders the requested file' "unexpected failure: ${(qqq)render_error}"
fi

if zsh "$tool_script" -- "$sample_file" "$other_file" >| "$stdout_file" 2>| "$stderr_file"; then
  _not_ok 'extra operands after -- are rejected' 'command unexpectedly succeeded'
else
  exit_code=$?
  render_error=$(<"$stderr_file")
  _assert_eq 'extra operands after -- exit with usage error status' "$exit_code" '2'
  _assert_contains 'extra operands after -- report the supported-operand limit' "$render_error" 'only one input file is supported'
fi

integer fd
exec {fd}< <(awk '/^local -a requested_highlighters/{exit} {print}' "$tool_script") || {
  print -r -- '1..1'
  print -r -- 'not ok 1 - load render helper functions'
  exit 1
}
source /dev/fd/$fd || {
  exec {fd}<&-
  print -r -- '1..1'
  print -r -- 'not ok 1 - load render helper functions'
  exit 1
}
exec {fd}<&-

_assert_sgr 'fg palette color parses' 'fg=123' '38;5;123'
_assert_sgr 'bg palette color parses' 'bg=123' '48;5;123'
_assert_sgr 'fg hex color parses' 'fg=#aabbcc' '38;2;170;187;204'
_assert_sgr 'bg hex color parses' 'bg=#aabbcc' '48;2;170;187;204'
_assert_sgr 'named colors remain supported' 'fg=blue' '34'

if (
  emulate -LR zsh
  typeset -gA _render_invocation_options=(ignoreclosebraces off)
  typeset -ga _render_syntax_option_names=(ignoreclosebraces codex_fake_missing_option)
  _render_restore_syntax_options
) 2>| "$stderr_file"; then
  render_error=$(<"$stderr_file")
  _assert_eq 'missing syntax options are skipped without stderr noise' "$render_error" ''
else
  _not_ok 'missing syntax options are skipped without stderr noise' "unexpected failure: ${(qqq)$(<"$stderr_file")}"
fi

typeset -gr comment_file=$temp_dir/comment.zsh
typeset -gr posix_file=$temp_dir/posix.zsh
print -r -- 'foo () # note' >| "$comment_file"
print -r -- 'command zstyle' >| "$posix_file"

_run_render "$comment_file"
_assert_contains 'comment text stays non-comment without interactivecomments' "$rendered_output" $'\033[31;1m#\033[0m note'

_run_render "$comment_file" interactivecomments
_assert_eq 'interactivecomments render exits cleanly' "$render_exit" '0'
_assert_contains 'interactivecomments colors the full comment body' "$rendered_output" $'\033[30;1m# note\033[0m'

_run_render "$posix_file"
_assert_contains 'posixbuiltins-off keeps command zstyle unresolved' "$rendered_output" $'\033[31;1mzstyle\033[0m'

_run_render "$posix_file" posixbuiltins
_assert_eq 'posixbuiltins render exits cleanly' "$render_exit" '0'
_assert_contains 'posixbuiltins colors command zstyle as a builtin' "$rendered_output" $'\033[32mzstyle\033[0m'

print -r -- "1..$test_count"
exit "$failure_count"
