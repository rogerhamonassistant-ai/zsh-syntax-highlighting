BUFFER=': ${var: -2} ${var: -4:2}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 12 default' # ${var: -2}
  '3 12 parameter-expansion' # ${var: -2}
  '4 4 parameter-expansion-delimiter' # {
  '8 8 parameter-expansion-operator' # :
  '12 12 parameter-expansion-delimiter' # }
  '14 25 default' # ${var: -4:2}
  '14 25 parameter-expansion' # ${var: -4:2}
  '15 15 parameter-expansion-delimiter' # {
  '19 19 parameter-expansion-operator' # :
  '23 23 parameter-expansion-operator' # :
  '25 25 parameter-expansion-delimiter' # }
)
