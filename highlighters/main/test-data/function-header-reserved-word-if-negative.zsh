BUFFER='if () { :; }'

expected_region_highlight=(
  '1 2 reserved-word' # if
  '4 5 unknown-token' # ()
  '7 7 reserved-word' # {
  '9 9 builtin' # :
  '10 10 commandseparator' # ;
  '12 12 reserved-word' # }
)
