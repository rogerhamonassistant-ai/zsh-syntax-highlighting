setopt interactivecomments

BUFFER=$'${foo:F:2:h}\n# note\n() { :; }'
unsorted=1

expected_region_highlight=(
  '1 12 unknown-token' # ${foo:F:2:h}
  '13 13 commandseparator' # newline
  '14 19 comment' # # note
  '20 20 commandseparator' # newline
  '21 22 reserved-word' # ()
  '24 24 reserved-word' # {
  '26 26 builtin' # :
  '27 27 commandseparator' # ;
  '29 29 reserved-word' # }
)
