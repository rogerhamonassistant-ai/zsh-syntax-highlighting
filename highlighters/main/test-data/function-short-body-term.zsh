BUFFER='function foo; :'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '13 13 commandseparator' # ;
  '15 15 reserved-word' # :
)
