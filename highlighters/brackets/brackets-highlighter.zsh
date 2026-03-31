# -------------------------------------------------------------------------------------------------
# Copyright (c) 2010-2017 zsh-syntax-highlighting contributors
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice, this list of conditions
#    and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice, this list of
#    conditions and the following disclaimer in the documentation and/or other materials provided
#    with the distribution.
#  * Neither the name of the zsh-syntax-highlighting contributors nor the names of its contributors
#    may be used to endorse or promote products derived from this software without specific prior
#    written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# -------------------------------------------------------------------------------------------------
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
# -------------------------------------------------------------------------------------------------


# Define default styles.
: ${ZSH_HIGHLIGHT_STYLES[bracket-error]:=fg=red,bold}
: ${ZSH_HIGHLIGHT_STYLES[bracket-level-1]:=fg=blue,bold}
: ${ZSH_HIGHLIGHT_STYLES[bracket-level-2]:=fg=green,bold}
: ${ZSH_HIGHLIGHT_STYLES[bracket-level-3]:=fg=magenta,bold}
: ${ZSH_HIGHLIGHT_STYLES[bracket-level-4]:=fg=yellow,bold}
: ${ZSH_HIGHLIGHT_STYLES[bracket-level-5]:=fg=cyan,bold}
: ${ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]:=standout}

typeset -g _zsh_highlight_brackets__native_add_highlight_source=${functions_source[_zsh_highlight_add_highlight]-}
typeset -g _zsh_highlight_brackets__cache_buffer=''
typeset -g _zsh_highlight_brackets__cache_rcquotes='off'
typeset -g _zsh_highlight_brackets__cache_histchars='!^#'
typeset -g _zsh_highlight_brackets__cache_style_signature=''
typeset -gi _zsh_highlight_brackets__cache_bracket_color_size=0
typeset -ga _zsh_highlight_brackets__cache_regions
typeset -ga _zsh_highlight_brackets__cache_rendered_regions
typeset -gA _zsh_highlight_brackets__cache_matching

_zsh_highlight_brackets__effective_rcquotes_setting()
{
  local user_rcquotes_setting=${zsyh_user_options[rcquotes]-off}

  if [[ $user_rcquotes_setting == on || -o rcquotes ]]; then
    REPLY=on
  else
    REPLY=off
  fi
}

_zsh_highlight_brackets__style_signature()
{
  integer bracket_color_size=$1 level
  local -a signature_parts

  signature_parts=("bracket-error:${ZSH_HIGHLIGHT_STYLES[bracket-error]-}")
  for (( level = 1; level <= bracket_color_size; ++level )); do
    signature_parts+=("bracket-level-$level:${ZSH_HIGHLIGHT_STYLES[bracket-level-$level]-}")
  done

  REPLY="${(j:$'\x1f':)signature_parts}"
}

# Whether the brackets highlighter should be called or not.
_zsh_highlight_highlighter_brackets_predicate()
{
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.predicate_calls'
  if [[ $WIDGET == zle-line-finish ]]; then
    (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.predicate_line_finish_hits'
    return 0
  fi

  if _zsh_highlight_cursor_moved; then
    (( _zsh_highlight_perf_trace_enabled )) && {
      _zsh_highlight_perf_count 'brackets.predicate_cursor_moved_hits'
      if [[ $BUFFER == "$_ZSH_HIGHLIGHT_PRIOR_BUFFER" ]]; then
        _zsh_highlight_perf_count 'brackets.predicate_cursor_only_hits'
      else
        _zsh_highlight_perf_count 'brackets.predicate_buffer_modified_hits'
      fi
    }
    return 0
  fi

  if _zsh_highlight_buffer_modified; then
    (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.predicate_buffer_modified_hits'
    return 0
  fi

  return 1
}

_zsh_highlight_brackets__cache_valid_p()
{
  local rcquotes_setting style_signature
  local histchars_setting=${histchars-'!^#'}
  integer bracket_color_size=$1

  _zsh_highlight_brackets__effective_rcquotes_setting
  rcquotes_setting=$REPLY
  _zsh_highlight_brackets__style_signature $bracket_color_size
  style_signature=$REPLY

  [[ $_zsh_highlight_brackets__cache_buffer == "$BUFFER" ]] &&
  [[ $_zsh_highlight_brackets__cache_rcquotes == "$rcquotes_setting" ]] &&
  [[ $_zsh_highlight_brackets__cache_histchars == "$histchars_setting" ]] &&
  [[ $_zsh_highlight_brackets__cache_style_signature == "$style_signature" ]] &&
  (( _zsh_highlight_brackets__cache_bracket_color_size == bracket_color_size ))
}

_zsh_highlight_brackets__replay_cached_regions()
{
  region_highlight+=("${_zsh_highlight_brackets__cache_rendered_regions[@]}")
}

_zsh_highlight_brackets__render_regions()
{
  integer rendered_index=1
  local -a rendered_regions
  local start end_ style

  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.rendered_region_builds'
  for start end_ style in "$@"; do
    rendered_regions[$rendered_index]="$start $end_ ${ZSH_HIGHLIGHT_STYLES[$style]}, memo=zsh-syntax-highlighting"
    (( rendered_index++ ))
  done
  reply=("${rendered_regions[@]}")
}

_zsh_highlight_brackets__apply_cursor_overlay()
{
  [[ $WIDGET == zle-line-finish ]] && return 0

  integer pos=$(( CURSOR + 1 ))
  if (( $+_zsh_highlight_brackets__cache_matching[$pos] )); then
    integer otherpos=${_zsh_highlight_brackets__cache_matching[$pos]}
    _zsh_highlight_add_highlight $(( otherpos - 1 )) "$otherpos" cursor-matchingbracket
  fi
}

_zsh_highlight_brackets_skip_quoted_region()
{
  local mode=$1
  integer pos=$2 origin=$2
  local char
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.skip_quoted_region_calls'

  while (( pos <= $#BUFFER )); do
    char=$BUFFER[$pos]
    case $mode in
      (single)
        if [[ $char == "'" ]]; then
          if [[ ${zsyh_user_options[rcquotes]:-off} == on || -o rcquotes ]] &&
             [[ $BUFFER[$(( pos + 1 ))] == "'" ]]
          then
            (( pos += 2 ))
            continue
          fi
          (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.skip_quoted_region_chars' $(( pos - origin + 1 ))
          REPLY=$pos
          return 0
        fi
        ;;
      (dollar-single)
        if [[ $char == '\' ]]; then
          (( pos += 2 ))
          continue
        fi
        case $mode:$char in
          (dollar-single:"'")
            (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.skip_quoted_region_chars' $(( pos - origin + 1 ))
            REPLY=$pos
            return 0
            ;;
        esac
        ;;
    esac
    (( pos++ ))
  done

  REPLY=$(( pos - 1 ))
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.skip_quoted_region_chars' $(( REPLY - origin + 1 ))
  return 1
}

_zsh_highlight_brackets_is_effectively_escaped_in_backtick()
{
  integer pos=$(( $1 - 1 )) raw_backslashes=0
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.backtick_escape_probe_calls'

  while (( pos > 0 )) && [[ $BUFFER[$pos] == '\' ]]; do
    (( raw_backslashes++ ))
    (( pos-- ))
  done

  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.backtick_escape_probe_backslashes' $raw_backslashes
  (( raw_backslashes > 0 )) || return 1
  (( raw_backslashes % 4 == 1 || raw_backslashes % 4 == 2 ))
}

_zsh_highlight_brackets_is_arithmetic_expansion()
{
  integer pos=$(( $1 + 3 )) origin=$(( $1 + 3 )) paren_depth=0
  local char quote_mode=''
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.arithmetic_probe_calls'

  while (( pos <= $#BUFFER )); do
    char=$BUFFER[$pos]

    case $quote_mode:$char in
      (single:"'")
        if [[ ${zsyh_user_options[rcquotes]:-off} == on || -o rcquotes ]] &&
           [[ $BUFFER[$(( pos + 1 ))] == "'" ]]
        then
          (( pos += 2 ))
          continue
        fi
        quote_mode=''
        (( pos++ ))
        continue
        ;;
      (dollar-single:"\\")
        (( pos += 2 ))
        continue
        ;;
      (dollar-single:"'")
        quote_mode=''
        (( pos++ ))
        continue
        ;;
      (double:"\\")
        (( pos += 2 ))
        continue
        ;;
      (double:'"')
        quote_mode=''
        (( pos++ ))
        continue
        ;;
      (backtick:"\\")
        if [[ ${BUFFER[$(( pos + 1 ))]:-} == [\$\\\`] ]]; then
          (( pos += 2 ))
        else
          (( pos++ ))
        fi
        continue
        ;;
      (backtick:'`')
        quote_mode=''
        (( pos++ ))
        continue
        ;;
    esac

    if [[ -n $quote_mode ]]; then
      (( pos++ ))
      continue
    fi

    case $char in
      "\\")
        if [[ ${BUFFER[$(( pos + 1 ))]:-} == ')' ]]; then
          (( pos += 2 ))
          continue
        fi
        ;;
      '$')
        if [[ ${BUFFER[$(( pos + 1 ))]:-} == "'" ]]; then
          quote_mode=dollar-single
          (( pos += 2 ))
          continue
        fi
        ;;
      "'")
        quote_mode=single
        ;;
      '"')
        quote_mode=double
        ;;
      '`')
        quote_mode=backtick
        ;;
      '(')
        (( paren_depth++ ))
        ;;
      ')')
        if (( paren_depth )); then
          (( paren_depth-- ))
        elif [[ ${BUFFER[$(( pos + 1 ))]:-} == ')' ]]; then
          (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.arithmetic_probe_chars' $(( pos - origin + 2 ))
          REPLY=$(( pos + 1 ))
          return 0
        else
          (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.arithmetic_probe_chars' $(( pos - origin + 1 ))
          return 1
        fi
        ;;
    esac
    (( pos++ ))
  done

  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.arithmetic_probe_chars' $(( pos - origin ))
  return 1
}

# Brackets highlighting function.
_zsh_highlight_highlighter_brackets_paint()
{
  local char literal_key prev_char
  local -i bracket_color_size=${#ZSH_HIGHLIGHT_STYLES[(I)bracket-level-*]} buflen=${#BUFFER} level=0 matchingpos pos in_double_quote=0 shell_code_paren_depth=0 pending_command_substitution=0 pending_arithmetic_parens=0
  local -a shell_code_double_quote_depths shell_code_scope_ids shell_code_scope_base_depths arithmetic_group_depths arithmetic_close_pending_depths arithmetic_scope_shell_depths arithmetic_scope_backtick_depths backtick_scope_ids backtick_base_shell_depths backtick_double_quote_states
  local -i next_shell_code_scope_id=0 next_backtick_scope_id=0
  local -A levelpos lastoflevel matching literal_level literal_levelpos literal_lastoflevel literal_matching
  local -a cache_regions
  local rcquotes_setting style_signature
  (( _zsh_highlight_perf_trace_enabled )) && {
    _zsh_highlight_perf_count 'brackets.paint_calls'
    _zsh_highlight_perf_count 'brackets.paint_chars' $buflen
  }
  _zsh_highlight_brackets__effective_rcquotes_setting
  rcquotes_setting=$REPLY
  _zsh_highlight_brackets__style_signature $bracket_color_size
  style_signature=$REPLY

  if _zsh_highlight_brackets__cache_valid_p $bracket_color_size; then
    (( _zsh_highlight_perf_trace_enabled )) && {
      _zsh_highlight_perf_count 'brackets.cache_reuse_hits'
      _zsh_highlight_perf_count 'brackets.cache_region_replays' $(( $#_zsh_highlight_brackets__cache_regions / 3 ))
    }
    _zsh_highlight_brackets__replay_cached_regions
    _zsh_highlight_brackets__apply_cursor_overlay
    return 0
  fi

  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.cache_rebuilds'
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.full_scan_calls'

  # Find all brackets and remember which one is matching
  pos=0
  while (( ++pos <= buflen )); do
    char=$BUFFER[$pos]
    integer shell_code_double_quote_active=0 arithmetic_active=0 backtick_active=0 current_shell_code_scope_id=0 current_backtick_scope_id=0 current_backtick_base_shell_depth=0 current_backtick_double_quote_active=0 nested_shell_code_active=0
    if (( $#shell_code_double_quote_depths )) && (( shell_code_double_quote_depths[-1] == shell_code_paren_depth )); then
      shell_code_double_quote_active=1
    fi
    if (( $#backtick_scope_ids )); then
      backtick_active=1
      current_backtick_scope_id=$backtick_scope_ids[-1]
      current_backtick_base_shell_depth=$backtick_base_shell_depths[-1]
      current_backtick_double_quote_active=$backtick_double_quote_states[-1]
    fi
    if (( shell_code_paren_depth > 0 )) &&
       ( (( ! backtick_active )) || (( shell_code_paren_depth > current_backtick_base_shell_depth )) )
    then
      nested_shell_code_active=1
    fi
    (( $#shell_code_scope_ids )) && current_shell_code_scope_id=$shell_code_scope_ids[-1]
    (( $#backtick_scope_ids )) && current_backtick_scope_id=$backtick_scope_ids[-1]
    if (( $#arithmetic_group_depths )) &&
       (( $#shell_code_scope_ids == ${arithmetic_scope_shell_depths[-1]:-0} )) &&
       (( $#backtick_scope_ids == ${arithmetic_scope_backtick_depths[-1]:-0} ))
    then
      arithmetic_active=1
    fi
    if (( in_double_quote )) && (( ! nested_shell_code_active )); then
      case $char in
        ('\\')
          if (( arithmetic_active )); then
            continue
          elif (( backtick_active )); then
            if [[ ${BUFFER[$(( pos + 1 ))]:-} == [\\\`\$\'] ]]; then
              (( pos++ ))
            fi
          elif [[ \\\`\"\$${histchars[1]}\' == *$BUFFER[$(( pos + 1 ))]* ]]; then
            (( pos++ ))
          fi
          continue
          ;;
        ("'")
          if (( ! arithmetic_active )) &&
             (( shell_code_paren_depth > 0 )) && (( ! shell_code_double_quote_active )) &&
             ( (( ! backtick_active )) || (( shell_code_paren_depth > current_backtick_base_shell_depth )) )
          then
            _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
            pos=$REPLY
            continue
          fi
          ;;
        ('"')
          if (( arithmetic_active )); then
            :
          elif (( backtick_active )) &&
               _zsh_highlight_brackets_is_effectively_escaped_in_backtick $pos
          then
            continue
          elif (( backtick_active )) && (( shell_code_paren_depth > current_backtick_base_shell_depth )); then
            if (( shell_code_double_quote_active )); then
              shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
            else
              shell_code_double_quote_depths+=($shell_code_paren_depth)
            fi
          elif (( backtick_active )); then
            backtick_double_quote_states[-1]=$(( ! current_backtick_double_quote_active ))
          elif (( shell_code_paren_depth == 0 )); then
            in_double_quote=0
          elif (( ! backtick_active )); then
            if (( shell_code_double_quote_active )); then
              shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
            else
              shell_code_double_quote_depths+=($shell_code_paren_depth)
            fi
          fi
          continue
          ;;
        ('$')
          if [[ $BUFFER[$(( pos + 1 )),$(( pos + 2 ))] == '((' ]]; then
            if _zsh_highlight_brackets_is_arithmetic_expansion $pos; then
              pending_arithmetic_parens=2
            else
              pending_command_substitution=1
            fi
          elif (( ! arithmetic_active )) &&
             (( shell_code_paren_depth > 0 )) && (( ! shell_code_double_quote_active )) &&
             ( (( ! backtick_active )) || (( shell_code_paren_depth > current_backtick_base_shell_depth )) ) &&
             [[ $BUFFER[$(( pos + 1 ))] == "'" ]]
          then
            _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
            pos=$REPLY
            continue
          elif [[ $BUFFER[$(( pos + 1 ))] == '(' ]]; then
            pending_command_substitution=1
          fi
          ;;
        ('`')
          if (( backtick_active )) && (( shell_code_paren_depth == current_backtick_base_shell_depth )); then
            if (( $#backtick_scope_ids > 1 )); then
              backtick_scope_ids=("${backtick_scope_ids[1,-2]}")
              backtick_base_shell_depths=("${backtick_base_shell_depths[1,-2]}")
              backtick_double_quote_states=("${backtick_double_quote_states[1,-2]}")
            else
              backtick_scope_ids=()
              backtick_base_shell_depths=()
              backtick_double_quote_states=()
            fi
          else
            backtick_scope_ids+=( $(( ++next_backtick_scope_id )) )
            backtick_base_shell_depths+=($shell_code_paren_depth)
            backtick_double_quote_states+=(0)
          fi
          continue
          ;;
      esac
    fi
    case $char in
      "'")
        if (( arithmetic_active )); then
          :
        elif (( backtick_active )); then
          if (( shell_code_paren_depth > current_backtick_base_shell_depth )); then
            if (( ! shell_code_double_quote_active )); then
              _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
              pos=$REPLY
              continue
            fi
          elif (( ! current_backtick_double_quote_active )); then
            _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
            pos=$REPLY
            continue
          fi
        elif (( ! in_double_quote )) && (( ! shell_code_double_quote_active )); then
          _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
          pos=$REPLY
          continue
        fi
        ;;
      '"')
        if (( arithmetic_active )); then
          :
        elif (( backtick_active )) &&
             _zsh_highlight_brackets_is_effectively_escaped_in_backtick $pos
        then
          continue
        elif (( backtick_active )); then
          if (( shell_code_paren_depth > current_backtick_base_shell_depth )); then
            if (( shell_code_double_quote_active )); then
              shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
            else
              shell_code_double_quote_depths+=($shell_code_paren_depth)
            fi
          else
            backtick_double_quote_states[-1]=$(( ! current_backtick_double_quote_active ))
          fi
        elif (( shell_code_paren_depth > 0 )); then
          if (( shell_code_double_quote_active )); then
            shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
          else
            shell_code_double_quote_depths+=($shell_code_paren_depth)
          fi
        else
          in_double_quote=1
        fi
        continue
        ;;
      '$')
        if [[ $BUFFER[$(( pos + 1 )),$(( pos + 2 ))] == '((' ]]; then
          if _zsh_highlight_brackets_is_arithmetic_expansion $pos; then
            pending_arithmetic_parens=2
          else
            pending_command_substitution=1
          fi
        elif [[ $BUFFER[$(( pos + 1 ))] == "'" ]]; then
          if (( backtick_active )); then
            if (( ! arithmetic_active )) && (( shell_code_paren_depth > current_backtick_base_shell_depth )); then
              if (( ! shell_code_double_quote_active )); then
                _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
                pos=$REPLY
                continue
              fi
            elif (( ! arithmetic_active )) && (( ! current_backtick_double_quote_active )); then
              _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
              pos=$REPLY
              continue
            fi
          elif (( ! arithmetic_active )) && (( ! in_double_quote )) && (( ! shell_code_double_quote_active )); then
            _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
            pos=$REPLY
            continue
          fi
        elif [[ $BUFFER[$(( pos + 1 ))] == '(' ]]; then
          pending_command_substitution=1
        fi
        ;;
      [\<\>\=])
        if (( ! arithmetic_active )) &&
           [[ $BUFFER[$(( pos + 1 ))] == '(' ]]
        then
          prev_char=${BUFFER[$(( pos - 1 ))]:-}
          if [[ $char == '=' ]] &&
             (( pos > 1 )) &&
             [[ $prev_char != [[:space:]] ]] &&
             [[ $prev_char != [\;\|\&\(] ]]
          then
            :
          elif (( backtick_active )); then
            if (( shell_code_paren_depth > current_backtick_base_shell_depth )); then
              (( ! shell_code_double_quote_active )) && pending_command_substitution=1
            elif (( ! current_backtick_double_quote_active )); then
              pending_command_substitution=1
            fi
          elif (( shell_code_paren_depth > 0 )); then
            (( ! shell_code_double_quote_active )) && pending_command_substitution=1
          elif (( ! in_double_quote )); then
            pending_command_substitution=1
          fi
        fi
        ;;
      "\\")
        if (( arithmetic_active )); then
          continue
        elif (( backtick_active )); then
          if [[ ${BUFFER[$(( pos + 1 ))]:-} == [\\\`\$\'] ]]; then
            (( pos++ ))
          fi
        else
          if (( shell_code_double_quote_active )) &&
             [[ ${BUFFER[$(( pos + 1 ))]:-} == [\(\)\[\]\{\}] ]]
          then
            continue
          elif [[ ${BUFFER[$(( pos + 1 ))]:-} == [\(\)\[\]\{\}] ]]; then
            literal_levelpos[$(( pos + 1 ))]=-1
            (( pos++ ))
          else
            (( pos++ ))
          fi
        fi
        continue
        ;;
      '`')
        if (( backtick_active )) && (( shell_code_paren_depth == current_backtick_base_shell_depth )); then
          if (( $#backtick_scope_ids > 1 )); then
            backtick_scope_ids=("${backtick_scope_ids[1,-2]}")
            backtick_base_shell_depths=("${backtick_base_shell_depths[1,-2]}")
            backtick_double_quote_states=("${backtick_double_quote_states[1,-2]}")
          else
            backtick_scope_ids=()
            backtick_base_shell_depths=()
            backtick_double_quote_states=()
          fi
        else
          backtick_scope_ids+=( $(( ++next_backtick_scope_id )) )
          backtick_base_shell_depths+=($shell_code_paren_depth)
          backtick_double_quote_states+=(0)
        fi
        continue
        ;;
    esac
    case $char in
      ["([{"])
        if (( backtick_active )) &&
           _zsh_highlight_brackets_is_effectively_escaped_in_backtick $pos
        then
          literal_levelpos[$pos]=-1
          continue
        fi
        if (
             (
               (( shell_code_double_quote_active )) ||
               ( (( in_double_quote )) && (( shell_code_paren_depth == 0 )) )
             ) &&
             (( ! backtick_active )) && (( ! pending_command_substitution )) && (( ! pending_arithmetic_parens ))
           ) || (
             (( backtick_active )) &&
             (
               ( (( shell_code_paren_depth > current_backtick_base_shell_depth )) && (( shell_code_double_quote_active )) ) ||
               ( (( shell_code_paren_depth == current_backtick_base_shell_depth )) && (( current_backtick_double_quote_active )) )
             ) &&
             (( ! pending_command_substitution )) && (( ! pending_arithmetic_parens ))
           )
        then
          if (( backtick_active )); then
            literal_key="backtick:$current_backtick_scope_id:$current_shell_code_scope_id:$shell_code_paren_depth"
          elif (( shell_code_paren_depth > 0 )); then
            literal_key="$current_shell_code_scope_id:$shell_code_paren_depth"
          else
            literal_key="quote:$level"
          fi
          integer current_literal_level=${literal_level[$literal_key]:-0}
          literal_levelpos[$pos]=$(( ++current_literal_level ))
          literal_level[$literal_key]=$current_literal_level
          literal_lastoflevel[$literal_key:$current_literal_level]=$pos
        else
          levelpos[$pos]=$((++level))
          lastoflevel[$level]=$pos
          if (( pending_arithmetic_parens )) && [[ $char == '(' ]]; then
            (( pending_arithmetic_parens-- ))
            if (( pending_arithmetic_parens == 0 )); then
              arithmetic_group_depths+=(0)
              arithmetic_close_pending_depths+=(0)
              arithmetic_scope_shell_depths+=($#shell_code_scope_ids)
              arithmetic_scope_backtick_depths+=($#backtick_scope_ids)
            fi
          elif (( arithmetic_active )) && [[ $char == '(' ]]; then
            (( arithmetic_group_depths[-1]++ ))
          fi
          if (( pending_command_substitution )) && [[ $char == '(' ]]; then
            (( shell_code_paren_depth++ ))
            pending_command_substitution=0
            shell_code_scope_ids+=( $(( ++next_shell_code_scope_id )) )
            shell_code_scope_base_depths+=( $shell_code_paren_depth )
          elif (( shell_code_paren_depth > 0 )) && [[ $char == '(' ]] && (( ! shell_code_double_quote_active )) &&
               ( (( ! backtick_active )) || (( shell_code_paren_depth > current_backtick_base_shell_depth )) )
          then
            (( shell_code_paren_depth++ ))
          fi
        fi
        ;;
      [")]}"])
        if (( backtick_active )) &&
           _zsh_highlight_brackets_is_effectively_escaped_in_backtick $pos
        then
          literal_levelpos[$pos]=-1
          continue
        fi
        if (
             (
               (( shell_code_double_quote_active )) ||
               ( (( in_double_quote )) && (( shell_code_paren_depth == 0 )) )
             ) &&
             (( ! backtick_active ))
           ) || (
             (( backtick_active )) &&
             (
               ( (( shell_code_paren_depth > current_backtick_base_shell_depth )) && (( shell_code_double_quote_active )) ) ||
               ( (( shell_code_paren_depth == current_backtick_base_shell_depth )) && (( current_backtick_double_quote_active )) )
             )
           )
        then
          if (( backtick_active )); then
            literal_key="backtick:$current_backtick_scope_id:$current_shell_code_scope_id:$shell_code_paren_depth"
          elif (( shell_code_paren_depth > 0 )); then
            literal_key="$current_shell_code_scope_id:$shell_code_paren_depth"
          else
            literal_key="quote:$level"
          fi
          integer current_literal_level=${literal_level[$literal_key]:-0}
          if (( current_literal_level > 0 )); then
            matchingpos=$literal_lastoflevel[$literal_key:$current_literal_level]
            literal_levelpos[$pos]=$current_literal_level
            (( literal_level[$literal_key] = current_literal_level - 1 ))
            if _zsh_highlight_brackets_match $matchingpos $pos; then
              literal_matching[$matchingpos]=$pos
              literal_matching[$pos]=$matchingpos
            fi
          else
            literal_levelpos[$pos]=-1
          fi
        elif (( level > 0 )); then
          matchingpos=$lastoflevel[$level]
          levelpos[$pos]=$((level--))
          if _zsh_highlight_brackets_match $matchingpos $pos; then
            matching[$matchingpos]=$pos
            matching[$pos]=$matchingpos
          fi
        else
          levelpos[$pos]=-1
        fi
        if (( shell_code_paren_depth > 0 )) && [[ $char == ')' ]] &&
           (( ! shell_code_double_quote_active )) &&
           ( (( ! backtick_active )) || (( shell_code_paren_depth > current_backtick_base_shell_depth )) )
        then
          if (( $#shell_code_scope_base_depths )) && (( shell_code_scope_base_depths[-1] == shell_code_paren_depth )); then
            shell_code_scope_ids=("${shell_code_scope_ids[1,-2]}")
            shell_code_scope_base_depths=("${shell_code_scope_base_depths[1,-2]}")
          fi
          (( shell_code_paren_depth-- ))
        fi
        if [[ $char == ')' ]] && (( pending_arithmetic_parens == 0 )) && (( $#arithmetic_group_depths )); then
          if (( arithmetic_close_pending_depths[-1] )); then
            arithmetic_group_depths=("${arithmetic_group_depths[1,-2]}")
            arithmetic_close_pending_depths=("${arithmetic_close_pending_depths[1,-2]}")
            arithmetic_scope_shell_depths=("${arithmetic_scope_shell_depths[1,-2]}")
            arithmetic_scope_backtick_depths=("${arithmetic_scope_backtick_depths[1,-2]}")
          elif (( arithmetic_group_depths[-1] > 0 )); then
            (( arithmetic_group_depths[-1]-- ))
          elif [[ ${BUFFER[$(( pos + 1 ))]:-} == ')' ]]; then
            arithmetic_close_pending_depths[-1]=1
          fi
        fi
        ;;
    esac
  done

  # Now highlight all found brackets
  for pos in ${(k)levelpos}; do
    if (( $+matching[$pos] )); then
      if (( bracket_color_size )); then
        cache_regions+=($(( pos - 1 )) $pos bracket-level-$(( (levelpos[$pos] - 1) % bracket_color_size + 1 )))
      fi
    else
      cache_regions+=($(( pos - 1 )) $pos bracket-error)
    fi
  done
  for pos in ${(k)literal_levelpos}; do
    if (( $+literal_matching[$pos] )); then
      if (( bracket_color_size )); then
        cache_regions+=($(( pos - 1 )) $pos bracket-level-$(( (literal_levelpos[$pos] - 1) % bracket_color_size + 1 )))
      fi
    fi
  done

  _zsh_highlight_brackets__cache_buffer=$BUFFER
  _zsh_highlight_brackets__cache_rcquotes=$rcquotes_setting
  _zsh_highlight_brackets__cache_histchars=${histchars-'!^#'}
  _zsh_highlight_brackets__cache_style_signature=$style_signature
  _zsh_highlight_brackets__cache_bracket_color_size=$bracket_color_size
  _zsh_highlight_brackets__cache_regions=("${cache_regions[@]}")
  _zsh_highlight_brackets__cache_matching=("${(kv)matching[@]}")
  if [[ ${functions_source[_zsh_highlight_add_highlight]-} == "$_zsh_highlight_brackets__native_add_highlight_source" ]]; then
    local -a reply
    _zsh_highlight_brackets__render_regions "${cache_regions[@]}"
    region_highlight=("${reply[@]}")
    _zsh_highlight_brackets__cache_rendered_regions=("${reply[@]}")
  else
    local start end_ style
    for start end_ style in "${cache_regions[@]}"; do
      _zsh_highlight_add_highlight "$start" "$end_" "$style"
    done
    _zsh_highlight_brackets__cache_rendered_regions=()
  fi
  (( _zsh_highlight_perf_trace_enabled )) && _zsh_highlight_perf_count 'brackets.cache_region_count' $(( $#cache_regions / 3 ))
  _zsh_highlight_brackets__apply_cursor_overlay
}

# Helper function to differentiate type 
_zsh_highlight_brackets_match()
{
  case $BUFFER[$1] in
    \() [[ $BUFFER[$2] == \) ]];;
    \[) [[ $BUFFER[$2] == \] ]];;
    \{) [[ $BUFFER[$2] == \} ]];;
    *) false;;
  esac
}
