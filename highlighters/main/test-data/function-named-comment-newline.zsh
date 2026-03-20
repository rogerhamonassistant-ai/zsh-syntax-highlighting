setopt interactivecomments

BUFFER=$'foo\n# note\n() { :; }'

expected_region_highlight=(
  '1 3 function' # foo
  '4 4 commandseparator' # newline
  '5 10 comment' # # note
  '11 11 commandseparator' # newline
  '12 13 reserved-word' # ()
  '15 15 reserved-word' # {
  '17 17 builtin' # :
  '18 18 commandseparator' # ;
  '20 20 reserved-word' # }
)
