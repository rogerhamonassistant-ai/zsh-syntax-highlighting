BUFFER=': ${foo:1:len} ${foo:1: len}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${foo:1:len}
  '3 14 parameter-expansion' # ${foo:1:len}
  '4 4 parameter-expansion-delimiter' # {
  '8 8 parameter-expansion-operator' # :
  '10 13 parameter-expansion-modifier' # :len
  '14 14 parameter-expansion-delimiter' # }
  '16 28 default' # ${foo:1: len}
  '16 28 parameter-expansion' # ${foo:1: len}
  '17 17 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-operator' # :
  '23 23 parameter-expansion-operator' # :
  '28 28 parameter-expansion-delimiter' # }
)
