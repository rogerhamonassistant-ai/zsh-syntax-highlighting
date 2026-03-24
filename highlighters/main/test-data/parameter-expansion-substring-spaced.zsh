BUFFER=': ${foo: offs} ${foo: +1} ${foo:1: +2}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${foo: offs}
  '3 14 parameter-expansion' # ${foo: offs}
  '4 4 parameter-expansion-delimiter' # {
  '8 8 parameter-expansion-operator' # :
  '14 14 parameter-expansion-delimiter' # }
  '16 25 default' # ${foo: +1}
  '16 25 parameter-expansion' # ${foo: +1}
  '17 17 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-operator' # :
  '25 25 parameter-expansion-delimiter' # }
  '27 38 default' # ${foo:1: +2}
  '27 38 parameter-expansion' # ${foo:1: +2}
  '28 28 parameter-expansion-delimiter' # {
  '32 32 parameter-expansion-operator' # :
  '34 34 parameter-expansion-operator' # :
  '38 38 parameter-expansion-delimiter' # }
)
