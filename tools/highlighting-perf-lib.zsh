#!/usr/bin/env zsh

typeset -ga ZSHH_PERF_SCENARIOS=(
  long-pipeline
  long-double-quoted-cmdsubst
  long-backtick-cmdsubst
  long-parameter-expansion
  long-arithmetic-subst
  long-glob-qualifiers
  option-nested-shell-code
  bracket-mix
  bracket-cursor-replay
)

zshh_perf_list_scenarios() {
  print -r -l -- "${ZSHH_PERF_SCENARIOS[@]}"
}

zshh_perf_generate_scenario() {
  local scenario=$1
  integer length=${2:-32} i
  local text=

  (( length > 0 )) || {
    print -u2 -- "highlighting-perf: length must be positive"
    return 1
  }

  case $scenario in
    (long-pipeline)
      text='print segment0001'
      for (( i = 2; i <= length; ++i )); do
        text+=" | print segment${(l:4::0:)i}"
      done
      ;;
    (long-double-quoted-cmdsubst)
      text='echo "'
      for (( i = 1; i <= length; ++i )); do
        text+="seg${(l:4::0:)i} "
        text+='$(print '
        text+="word${(l:4::0:)i}) "
      done
      text+='"'
      ;;
    (long-backtick-cmdsubst)
      text='echo "'
      for (( i = 1; i <= length; ++i )); do
        text+="seg${(l:4::0:)i} "
        text+='`print '
        text+="word${(l:4::0:)i}\` "
      done
      text+='"'
      ;;
    (long-parameter-expansion)
      text=': '
      for (( i = 1; i <= length; ++i )); do
        text+='${value:-segment'
        text+="${(l:4::0:)i}"
        text+='} '
      done
      ;;
    (long-arithmetic-subst)
      text=': $(( '
      for (( i = 1; i <= length; ++i )); do
        (( i > 1 )) && text+='+ '
        text+='$(print '
        text+="$i"
        text+=') '
      done
      text+='))'
      ;;
    (long-glob-qualifiers)
      text=': '
      for (( i = 1; i <= length; ++i )); do
        text+="item${(l:4::0:)i}(N.om[1,1]) "
      done
      ;;
    (option-nested-shell-code)
      text='git archive'
      for (( i = 1; i <= length; ++i )); do
        text+=' --prefix'
        text+="${(l:4::0:)i}"
        text+='="${repo'
        text+="${(l:4::0:)i}"
        text+='::=${$(git remote get-url origin):t:r}}/$(git rev-parse --short HEAD)"'
      done
      text+=' "${branch}"'
      ;;
    (bracket-mix)
      text='echo '
      for (( i = 1; i <= length; ++i )); do
        text+='$(print "(") '
        text+='<(print "[") '
        text+='>(print "]") '
      done
      ;;
    (bracket-cursor-replay)
      text='([{}])'
      for (( i = 2; i <= length; ++i )); do
        text+=' ([{}])'
      done
      ;;
    (*)
      print -u2 -- "highlighting-perf: unknown scenario: $scenario"
      return 1
      ;;
  esac

  REPLY=$text
}

zshh_perf_scenario_run_mode() {
  local scenario=$1

  case $scenario in
    (bracket-cursor-replay)
      REPLY=cursor-replay
      ;;
    (*)
      REPLY=single
      ;;
  esac
}

zshh_perf_load_input() {
  local input_file=$1

  zmodload zsh/mapfile || {
    print -u2 -- 'highlighting-perf: failed to load zsh/mapfile'
    return 1
  }

  [[ -f $input_file ]] || {
    print -u2 -- "highlighting-perf: not a file: $input_file"
    return 1
  }
  [[ -r $input_file ]] || {
    print -u2 -- "highlighting-perf: not readable: $input_file"
    return 1
  }

  REPLY=${mapfile[$input_file]}
}

zshh_perf_setup_runtime() {
  local tool_root=$1

  typeset -ga region_highlight
  zmodload zsh/zle || {
    print -u2 -- 'highlighting-perf: failed to load zsh/zle'
    return 1
  }

  source "$tool_root/zsh-syntax-highlighting.zsh" || {
    print -u2 -- 'highlighting-perf: failed to source zsh-syntax-highlighting.zsh'
    return 1
  }

  PREBUFFER=''
  MARK=0
  PENDING=0
  REGION_ACTIVE=0
  WIDGET=z-sy-h-test-harness-test-widget
  typeset -gi CURSOR=0
}

zshh_perf_force_repaint() {
  local buffer=${1-}

  typeset -g _ZSH_HIGHLIGHT_PRIOR_BUFFER="${buffer}"$'\x1f'
  typeset -gi _ZSH_HIGHLIGHT_PRIOR_CURSOR=-1
}

zshh_perf_validate_highlighters() {
  local tool_root=$1
  shift
  local highlighter

  for highlighter in "$@"; do
    [[ -f $tool_root/highlighters/$highlighter/$highlighter-highlighter.zsh ]] || {
      print -u2 -- "highlighting-perf: unknown highlighter: $highlighter"
      return 1
    }
  done
}

zshh_perf_run_highlight() {
  local buffer=$1
  shift
  local -a highlighters=("$@")

  ZSH_HIGHLIGHT_HIGHLIGHTERS=("${highlighters[@]}")
  BUFFER=$buffer
  CURSOR=$#BUFFER
  PREBUFFER=''
  region_highlight=()
  zshh_perf_force_repaint "$buffer"
  _zsh_highlight_perf_reset
  true && _zsh_highlight
}

zshh_perf_prime_highlight_cursor_replay() {
  local buffer=$1
  shift
  local -a highlighters=("$@")
  integer prime_cursor target_cursor

  zshh_perf_find_cursor_replay_positions "$buffer" || return 1
  prime_cursor=${REPLY%%:*}
  target_cursor=${REPLY#*:}

  ZSH_HIGHLIGHT_HIGHLIGHTERS=("${highlighters[@]}")
  BUFFER=$buffer
  PREBUFFER=''
  region_highlight=()

  CURSOR=$prime_cursor
  zshh_perf_force_repaint "$buffer"
  _zsh_highlight_perf_reset
  true && _zsh_highlight

  REPLY=$target_cursor
}

zshh_perf_find_cursor_replay_positions() {
  local buffer=$1
  integer pos first_cursor=-1 second_cursor=-1

  for (( pos = 1; pos <= $#buffer; ++pos )); do
    case $buffer[$pos] in
      [\(\)\[\]\{\}])
        if (( first_cursor < 0 )); then
          first_cursor=$(( pos - 1 ))
        else
          second_cursor=$(( pos - 1 ))
          break
        fi
        ;;
    esac
  done

  (( first_cursor >= 0 && second_cursor >= 0 )) || {
    print -u2 -- 'highlighting-perf: cursor replay scenario requires at least two bracket characters'
    return 1
  }

  REPLY="$first_cursor:$second_cursor"
}

zshh_perf_run_highlight_cursor_replay() {
  local buffer=$1
  integer target_cursor=$2
  shift 2
  local -a highlighters=("$@")

  ZSH_HIGHLIGHT_HIGHLIGHTERS=("${highlighters[@]}")
  BUFFER=$buffer
  PREBUFFER=''
  region_highlight=()

  CURSOR=$target_cursor
  _zsh_highlight_perf_reset
  true && _zsh_highlight
}

zshh_perf_dump_trace_tsv() {
  local prefix=$1
  local key

  for key in "${(@ok)_ZSH_HIGHLIGHT_PERF_COUNTERS}"; do
    print -r -- "$prefix"$'\t'"$key"$'\t'"${_ZSH_HIGHLIGHT_PERF_COUNTERS[$key]}"
  done
}
