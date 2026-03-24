BUFFER='function foo (); { :; }'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '14 15 reserved-word' # ()
  '16 16 commandseparator' # ;
  '18 18 reserved-word' # {
  '20 20 builtin' # :
  '21 21 commandseparator' # ;
  '23 23 reserved-word' # }
)
