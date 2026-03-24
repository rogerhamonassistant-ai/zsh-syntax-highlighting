BUFFER=': ${PATH:-/usr/bin:/bin} ${foo+http://host}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 24 default' # ${PATH:-/usr/bin:/bin}
  '3 24 parameter-expansion' # ${PATH:-/usr/bin:/bin}
  '4 4 parameter-expansion-delimiter' # {
  '9 10 parameter-expansion-operator' # :-
  '24 24 parameter-expansion-delimiter' # }
  '26 43 default' # ${foo+http://host}
  '26 43 parameter-expansion' # ${foo+http://host}
  '27 27 parameter-expansion-delimiter' # {
  '31 31 parameter-expansion-operator' # +
  '43 43 parameter-expansion-delimiter' # }
)
