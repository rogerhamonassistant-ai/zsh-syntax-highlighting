BUFFER='repeat () { :; }'

expected_region_highlight=(
  '1 6 reserved-word' # repeat
  '8 9 unknown-token' # ()
  '11 11 reserved-word' # {
  '13 13 builtin' # :
  '14 14 commandseparator' # ;
  '16 16 reserved-word' # }
)
