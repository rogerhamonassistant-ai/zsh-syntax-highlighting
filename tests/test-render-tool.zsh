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

print -r -- "1..$test_count"
exit "$failure_count"
