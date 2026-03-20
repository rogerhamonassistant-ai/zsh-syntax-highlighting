BUFFER=$'function foo\nbar { :; }'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '13 13 commandseparator' # newline
  '14 16 unknown-token' # bar
  '18 18 default' # {
  '20 20 default' # :
  '21 21 commandseparator' # ;
  '23 23 unknown-token' # }
)
