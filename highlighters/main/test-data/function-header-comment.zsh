setopt interactivecomments

BUFFER=$'function foo # note\n{ :; }'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '14 19 comment' # # note
  '20 20 commandseparator' # newline
  '21 21 reserved-word' # {
  '23 23 builtin' # :
  '24 24 commandseparator' # ;
  '26 26 reserved-word' # }
)
