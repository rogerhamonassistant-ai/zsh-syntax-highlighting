BUFFER='foo >out () { :; }'

expected_region_highlight=(
  '1 3 function' # foo
  '5 5 redirection' # >
  '6 8 default' # out
  '10 11 reserved-word' # ()
  '13 13 reserved-word' # {
  '15 15 builtin' # :
  '16 16 commandseparator' # ;
  '18 18 reserved-word' # }
)
