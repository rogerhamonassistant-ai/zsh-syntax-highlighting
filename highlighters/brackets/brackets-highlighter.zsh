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

# Whether the brackets highlighter should be called or not.
_zsh_highlight_highlighter_brackets_predicate()
{
  [[ $WIDGET == zle-line-finish ]] || _zsh_highlight_cursor_moved || _zsh_highlight_buffer_modified
}

_zsh_highlight_brackets_skip_quoted_region()
{
  local mode=$1
  integer pos=$2
  local char

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
            REPLY=$pos
            return 0
            ;;
        esac
        ;;
    esac
    (( pos++ ))
  done

  REPLY=$(( pos - 1 ))
  return 1
}

_zsh_highlight_brackets_is_arithmetic_expansion()
{
  integer pos=$(( $1 + 3 )) paren_depth=0
  local char quote_mode=''

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
      (double:"\\")
        (( pos += 2 ))
        continue
        ;;
      (double:'"')
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
      "'")
        quote_mode=single
        ;;
      '"')
        quote_mode=double
        ;;
      '(')
        (( paren_depth++ ))
        ;;
      ')')
        if (( paren_depth )); then
          (( paren_depth-- ))
        elif [[ ${BUFFER[$(( pos + 1 ))]:-} == ')' ]]; then
          REPLY=$(( pos + 1 ))
          return 0
        else
          return 1
        fi
        ;;
    esac
    (( pos++ ))
  done

  return 1
}

# Brackets highlighting function.
_zsh_highlight_highlighter_brackets_paint()
{
  local char style literal_key prev_char
  local -i bracket_color_size=${#ZSH_HIGHLIGHT_STYLES[(I)bracket-level-*]} buflen=${#BUFFER} level=0 matchingpos pos in_double_quote=0 shell_code_paren_depth=0 backtick_active=0 backtick_double_quote_active=0 backtick_base_shell_depth=0 pending_command_substitution=0 pending_arithmetic_parens=0
  local -a shell_code_double_quote_depths shell_code_scope_ids shell_code_scope_base_depths arithmetic_group_depths arithmetic_close_pending_depths arithmetic_scope_shell_depths arithmetic_scope_backtick_depths backtick_scope_ids
  local -i next_shell_code_scope_id=0 next_backtick_scope_id=0
  local -A levelpos lastoflevel matching literal_level literal_levelpos literal_lastoflevel literal_matching

  # Find all brackets and remember which one is matching
  pos=0
  while (( ++pos <= buflen )); do
    char=$BUFFER[$pos]
    integer shell_code_double_quote_active=0 arithmetic_active=0 current_shell_code_scope_id=0 current_backtick_scope_id=0 nested_shell_code_active=0
    if (( $#shell_code_double_quote_depths )) && (( shell_code_double_quote_depths[-1] == shell_code_paren_depth )); then
      shell_code_double_quote_active=1
    fi
    if (( shell_code_paren_depth > 0 )) &&
       ( (( ! backtick_active )) || (( shell_code_paren_depth > backtick_base_shell_depth )) )
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
            if [[ \\\`\$\"\' == *$BUFFER[$(( pos + 1 ))]* ]]; then
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
             ( (( ! backtick_active )) || (( shell_code_paren_depth > backtick_base_shell_depth )) )
          then
            _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
            pos=$REPLY
            continue
          fi
          ;;
        ('"')
          if (( arithmetic_active )); then
            :
          elif (( backtick_active )) && (( shell_code_paren_depth > backtick_base_shell_depth )); then
            if (( shell_code_double_quote_active )); then
              shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
            else
              shell_code_double_quote_depths+=($shell_code_paren_depth)
            fi
          elif (( backtick_active )); then
            backtick_double_quote_active=$(( ! backtick_double_quote_active ))
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
             ( (( ! backtick_active )) || (( shell_code_paren_depth > backtick_base_shell_depth )) ) &&
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
          backtick_active=$(( ! backtick_active ))
          if (( backtick_active )); then
            backtick_base_shell_depth=$shell_code_paren_depth
            backtick_scope_ids+=( $(( ++next_backtick_scope_id )) )
          else
            backtick_double_quote_active=0
            backtick_base_shell_depth=0
            (( $#backtick_scope_ids )) && backtick_scope_ids=("${backtick_scope_ids[1,-2]}")
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
          if (( shell_code_paren_depth > backtick_base_shell_depth )); then
            if (( ! shell_code_double_quote_active )); then
              _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
              pos=$REPLY
              continue
            fi
          elif (( ! backtick_double_quote_active )); then
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
        elif (( backtick_active )); then
          if (( shell_code_paren_depth > backtick_base_shell_depth )); then
            if (( shell_code_double_quote_active )); then
              shell_code_double_quote_depths=("${shell_code_double_quote_depths[1,-2]}")
            else
              shell_code_double_quote_depths+=($shell_code_paren_depth)
            fi
          else
            backtick_double_quote_active=$(( ! backtick_double_quote_active ))
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
            if (( ! arithmetic_active )) && (( shell_code_paren_depth > backtick_base_shell_depth )); then
              if (( ! shell_code_double_quote_active )); then
                _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
                pos=$REPLY
                continue
              fi
            elif (( ! arithmetic_active )) && (( ! backtick_double_quote_active )); then
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
            if (( shell_code_paren_depth > backtick_base_shell_depth )); then
              (( ! shell_code_double_quote_active )) && pending_command_substitution=1
            elif (( ! backtick_double_quote_active )); then
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
          if [[ \\\`\$\"\' == *$BUFFER[$(( pos + 1 ))]* ]]; then
            (( pos++ ))
          fi
        else
          if [[ ${BUFFER[$(( pos + 1 ))]:-} == [\(\)\[\]\{\}] ]]; then
            literal_levelpos[$(( pos + 1 ))]=-1
            (( pos++ ))
          else
            (( pos++ ))
          fi
        fi
        continue
        ;;
      '`')
        backtick_active=$(( ! backtick_active ))
        if (( backtick_active )); then
          backtick_base_shell_depth=$shell_code_paren_depth
          backtick_scope_ids+=( $(( ++next_backtick_scope_id )) )
        else
          backtick_double_quote_active=0
          backtick_base_shell_depth=0
          (( $#backtick_scope_ids )) && backtick_scope_ids=("${backtick_scope_ids[1,-2]}")
        fi
        continue
        ;;
    esac
    case $char in
      ["([{"])
        if (
             (
               (( shell_code_double_quote_active )) ||
               ( (( in_double_quote )) && (( shell_code_paren_depth == 0 )) )
             ) &&
             (( ! backtick_active )) && (( ! pending_command_substitution )) && (( ! pending_arithmetic_parens ))
           ) || (
             (( backtick_active )) &&
             (
               ( (( shell_code_paren_depth > backtick_base_shell_depth )) && (( shell_code_double_quote_active )) ) ||
               ( (( shell_code_paren_depth == backtick_base_shell_depth )) && (( backtick_double_quote_active )) )
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
               ( (( ! backtick_active )) || (( shell_code_paren_depth > backtick_base_shell_depth )) )
          then
            (( shell_code_paren_depth++ ))
          fi
        fi
        ;;
      [")]}"])
        if (
             (
               (( shell_code_double_quote_active )) ||
               ( (( in_double_quote )) && (( shell_code_paren_depth == 0 )) )
             ) &&
             (( ! backtick_active ))
           ) || (
             (( backtick_active )) &&
             (
               ( (( shell_code_paren_depth > backtick_base_shell_depth )) && (( shell_code_double_quote_active )) ) ||
               ( (( shell_code_paren_depth == backtick_base_shell_depth )) && (( backtick_double_quote_active )) )
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
           ( (( ! backtick_active )) || (( shell_code_paren_depth > backtick_base_shell_depth )) )
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
        _zsh_highlight_add_highlight $((pos - 1)) $pos bracket-level-$(( (levelpos[$pos] - 1) % bracket_color_size + 1 ))
      fi
    else
      _zsh_highlight_add_highlight $((pos - 1)) $pos bracket-error
    fi
  done
  for pos in ${(k)literal_levelpos}; do
    if (( $+literal_matching[$pos] )); then
      if (( bracket_color_size )); then
        _zsh_highlight_add_highlight $((pos - 1)) $pos bracket-level-$(( (literal_levelpos[$pos] - 1) % bracket_color_size + 1 ))
      fi
    else
      _zsh_highlight_add_highlight $((pos - 1)) $pos bracket-error
    fi
  done

  # If cursor is on a bracket, then highlight corresponding bracket, if any.
  if [[ $WIDGET != zle-line-finish ]]; then
    pos=$((CURSOR + 1))
    if (( $+levelpos[$pos] )) && (( $+matching[$pos] )); then
      local -i otherpos=$matching[$pos]
      _zsh_highlight_add_highlight $((otherpos - 1)) $otherpos cursor-matchingbracket
    fi
  fi
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
