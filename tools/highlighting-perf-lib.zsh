#!/usr/bin/env zsh

typeset -ga ZSHH_PERF_SCENARIOS=(
  long-pipeline
  long-double-quoted-cmdsubst
  long-backtick-cmdsubst
  long-parameter-expansion
  long-arithmetic-subst
  long-glob-qualifiers
  bracket-mix
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
    (bracket-mix)
      text='echo '
      for (( i = 1; i <= length; ++i )); do
        text+='$(print "(") '
        text+='<(print "[") '
        text+='>(print "]") '
      done
      ;;
    (*)
      print -u2 -- "highlighting-perf: unknown scenario: $scenario"
      return 1
      ;;
  esac

  REPLY=$text
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
  typeset -g _ZSH_HIGHLIGHT_PRIOR_BUFFER=''
  typeset -gi _ZSH_HIGHLIGHT_PRIOR_CURSOR=-1
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
  zshh_perf_force_repaint
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
