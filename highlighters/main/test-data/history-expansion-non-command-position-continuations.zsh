BUFFER=': !!:p ; : !!$ ; : !!foo'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 6 history-expansion' # !!:p
  '8 8 commandseparator' # ;
  '10 10 builtin' # :
  '12 14 history-expansion' # !!$
  '16 16 commandseparator' # ;
  '18 18 builtin' # :
  '20 24 history-expansion' # !!foo
)
