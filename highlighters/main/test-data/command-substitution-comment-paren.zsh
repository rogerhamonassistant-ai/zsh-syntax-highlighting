setopt interactivecomments

BUFFER=$': $(echo ok # )\nprint done)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 27 default' # $(echo ok # )\nprint done)
  '3 27 command-substitution-unquoted' # $(echo ok # )\nprint done)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 builtin' # echo
  '10 11 default' # ok
  '13 15 comment' # # )
  '16 16 commandseparator' # \n
  '17 21 builtin' # print
  '23 26 default' # done
  '27 27 command-substitution-delimiter-unquoted' # )
)
