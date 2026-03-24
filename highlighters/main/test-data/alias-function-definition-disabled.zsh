alias foo=bar

BUFFER='foo () { :; }'

expected_region_highlight=(
  '1 3 unknown-token' # foo
  '5 6 reserved-word' # ()
  '8 8 reserved-word' # {
  '10 10 builtin' # :
  '11 11 commandseparator' # ;
  '13 13 reserved-word' # }
)
