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
          if [[ -o rcquotes ]] && [[ $BUFFER[$(( pos + 1 ))] == "'" ]]; then
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

# Brackets highlighting function.
_zsh_highlight_highlighter_brackets_paint()
{
  local char style
  local -i bracket_color_size=${#ZSH_HIGHLIGHT_STYLES[(I)bracket-level-*]} buflen=${#BUFFER} level=0 matchingpos pos in_double_quote=0
  local -A levelpos lastoflevel matching

  # Find all brackets and remember which one is matching
  pos=0
  while (( ++pos <= buflen )); do
    char=$BUFFER[$pos]
    if (( in_double_quote )); then
      case $char in
        ('\\')
          (( pos++ ))
          continue
          ;;
        ('"')
          in_double_quote=0
          continue
          ;;
      esac
    fi
    case $char in
      "'")
        if (( ! in_double_quote )); then
          _zsh_highlight_brackets_skip_quoted_region single $(( pos + 1 ))
          pos=$REPLY
          continue
        fi
        ;;
      '"')
        in_double_quote=1
        continue
        ;;
      '$')
        if (( ! in_double_quote )) && [[ $BUFFER[$(( pos + 1 ))] == "'" ]]; then
          _zsh_highlight_brackets_skip_quoted_region dollar-single $(( pos + 2 ))
          pos=$REPLY
          continue
        fi
        ;;
      "\\")
        (( pos++ ))
        continue
        ;;
    esac
    case $char in
      ["([{"])
        levelpos[$pos]=$((++level))
        lastoflevel[$level]=$pos
        ;;
      [")]}"])
        if (( level > 0 )); then
          matchingpos=$lastoflevel[$level]
          levelpos[$pos]=$((level--))
          if _zsh_highlight_brackets_match $matchingpos $pos; then
            matching[$matchingpos]=$pos
            matching[$pos]=$matchingpos
          fi
        else
          levelpos[$pos]=-1
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
