setopt interactivecomments

BUFFER=$'function foo (); # note\n:'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '14 15 reserved-word' # ()
  '16 16 commandseparator' # ;
  '18 23 comment' # # note
  '24 24 commandseparator' # newline
  '25 25 reserved-word' # :
)
