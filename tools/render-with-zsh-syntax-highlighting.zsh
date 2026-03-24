#!/usr/bin/env zsh

emulate -LR zsh
setopt pipe_fail no_unset

zmodload zsh/zle || {
  print -u2 -- 'render-with-zsh-syntax-highlighting: failed to load zsh/zle'
  exit 1
}

typeset -g HISTFILE=
typeset -gi HISTSIZE=0 SAVEHIST=0
typeset -ga region_highlight

typeset -A _render_named_fg=(
  black 30 red 31 green 32 yellow 33 blue 34 magenta 35 cyan 36 white 37 default 39
  brightblack 90 brightred 91 brightgreen 92 brightyellow 93 brightblue 94 brightmagenta 95 brightcyan 96 brightwhite 97
)
typeset -A _render_named_bg=(
  black 40 red 41 green 42 yellow 43 blue 44 magenta 45 cyan 46 white 47 default 49
  brightblack 100 brightred 101 brightgreen 102 brightyellow 103 brightblue 104 brightmagenta 105 brightcyan 106 brightwhite 107
)

_render_usage() {
  cat <<'EOF'
usage: tools/render-with-zsh-syntax-highlighting.zsh [--highlighters main,brackets] FILE

Read FILE as text only and print ANSI-colored output using zsh-syntax-highlighting.
The file contents are never sourced or executed.
EOF
}

_render_die() {
  print -u2 -- "render-with-zsh-syntax-highlighting: $1"
  exit "${2:-1}"
}

_render_trim() {
  local value=$1
  value=${value##[[:space:]]#}
  value=${value%%[[:space:]]#}
  REPLY=$value
}

_render_parse_color_code() {
  local channel=$1 value=${2:l}
  local prefix

  if [[ $channel == fg ]]; then
    (( ${+_render_named_fg[$value]} )) && { REPLY=${_render_named_fg[$value]}; return 0; }
    prefix=38
  else
    (( ${+_render_named_bg[$value]} )) && { REPLY=${_render_named_bg[$value]}; return 0; }
    prefix=48
  fi

  if [[ $value =~ '^[0-9]+$' ]]; then
    (( value >= 0 && value <= 255 )) || return 1
    REPLY="$prefix;5;$value"
    return 0
  fi

  if [[ $value =~ '^#[0-9a-f]{6}$' ]]; then
    local hex=${value#\#}
    local -i red=$(( 16#${hex[1,2]} ))
    local -i green=$(( 16#${hex[3,4]} ))
    local -i blue=$(( 16#${hex[5,6]} ))
    REPLY="$prefix;2;$red;$green;$blue"
    return 0
  fi

  return 1
}

_render_style_to_sgr() {
  local spec=$1 token
  local -a sgr_codes

  spec=${spec%%, memo=*}
  [[ -n $spec ]] || return 1
  [[ $spec == none ]] && return 1

  for token in "${(@s:,:)spec}"; do
    _render_trim "$token"
    token=$REPLY
    [[ -n $token ]] || continue

    case $token in
      (memo=*)
        ;;
      (none)
        sgr_codes=(0)
        ;;
      (bold)
        sgr_codes+=(1)
        ;;
      (underline)
        sgr_codes+=(4)
        ;;
      (standout)
        sgr_codes+=(7)
        ;;
      (fg=*)
        _render_parse_color_code fg "${token#fg=}" && sgr_codes+=("$REPLY")
        ;;
      (bg=*)
        _render_parse_color_code bg "${token#bg=}" && sgr_codes+=("$REPLY")
        ;;
    esac
  done

  (( $#sgr_codes )) || return 1
  REPLY="${(j:;:)sgr_codes}"
  return 0
}

_render_emit_segment() {
  local spec=$1 text=$2

  if _render_style_to_sgr "$spec"; then
    printf '\033[%sm%s\033[0m' "$REPLY" "$text"
  else
    print -rn -- "$text"
  fi
}

_render_line() {
  local line=$1
  integer line_len=${#line}
  integer start end clipped_start clipped_end idx run_start pos
  local entry rest spec current_spec next_spec
  local -a style_at

  if (( line_len == 0 )); then
    print
    return 0
  fi

  style_at=()
  for (( idx = 1; idx <= line_len; ++idx )); do
    style_at[idx]=''
  done

  for entry in "${region_highlight[@]}"; do
    start=${entry%% *}
    rest=${entry#* }
    end=${rest%% *}
    spec=${rest#* }
    spec=${spec%%, memo=*}

    (( clipped_start = start + 1 ))
    (( clipped_end = end ))
    (( clipped_start < 1 )) && clipped_start=1
    (( clipped_end > line_len )) && clipped_end=$line_len
    (( clipped_start > clipped_end )) && continue

    for (( pos = clipped_start; pos <= clipped_end; ++pos )); do
      style_at[pos]=$spec
    done
  done

  run_start=1
  current_spec=$style_at[1]
  for (( pos = 2; pos <= line_len + 1; ++pos )); do
    if (( pos <= line_len )); then
      next_spec=$style_at[pos]
    else
      next_spec=$'\0'
    fi

    if [[ $next_spec != $current_spec ]]; then
      _render_emit_segment "$current_spec" "$line[$run_start,$(( pos - 1 ))]"
      run_start=$pos
      current_spec=$next_spec
    fi
  done
  print
}

local -a requested_highlighters
local highlighters_arg= file_arg=

while (( $# > 0 )); do
  case $1 in
    (--help|-h)
      _render_usage
      exit 0
      ;;
    (--highlighters)
      shift
      (( $# > 0 )) || _render_die '--highlighters requires a value' 2
      highlighters_arg=$1
      ;;
    (--highlighters=*)
      highlighters_arg=${1#--highlighters=}
      ;;
    (--)
      shift
      break
      ;;
    (-*)
      _render_die "unknown option: $1" 2
      ;;
    (*)
      if [[ -n $file_arg ]]; then
        _render_die 'only one input file is supported' 2
      fi
      file_arg=$1
      ;;
  esac
  shift
done

if (( $# > 0 )); then
  [[ -z $file_arg && $# -eq 1 ]] || _render_die 'only one input file is supported' 2
  file_arg=$1
  shift
fi

[[ -n $file_arg ]] || _render_die 'missing input file' 2
[[ -f $file_arg ]] || _render_die "not a file: $file_arg" 2
[[ -r $file_arg ]] || _render_die "not readable: $file_arg" 2

if [[ -n $highlighters_arg ]]; then
  requested_highlighters=("${(@s:,:)highlighters_arg}")
else
  requested_highlighters=(main)
fi

local idx highlighter
for (( idx = 1; idx <= $#requested_highlighters; ++idx )); do
  _render_trim "${requested_highlighters[idx]}"
  requested_highlighters[idx]=$REPLY
done
requested_highlighters=("${(@)requested_highlighters:#}")
(( $#requested_highlighters > 0 )) || _render_die 'no highlighters selected' 2

local root=${0:A:h:h}
for highlighter in "${requested_highlighters[@]}"; do
  [[ -f "$root/highlighters/$highlighter/$highlighter-highlighter.zsh" ]] ||
    _render_die "unknown highlighter: $highlighter" 2
done

source "$root/zsh-syntax-highlighting.zsh" ||
  _render_die 'failed to source zsh-syntax-highlighting.zsh'

ZSH_HIGHLIGHT_HIGHLIGHTERS=("${requested_highlighters[@]}")

local line
local PREBUFFER='' BUFFER='' REPLY='' MARK=0 PENDING=0 REGION_ACTIVE=0 WIDGET=z-sy-h-test-harness-test-widget
integer CURSOR=0
region_highlight=()

while IFS= read -r line || [[ -n $line ]]; do
  BUFFER=$line
  CURSOR=$#BUFFER
  region_highlight=()
  _zsh_highlight
  _render_line "$BUFFER"
  PREBUFFER+="$line"$'\n'
done < "$file_arg"
