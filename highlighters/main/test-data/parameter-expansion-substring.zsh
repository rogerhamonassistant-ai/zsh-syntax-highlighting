BUFFER=': ${var:1:2} ${var:$off:$len}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 12 default' # ${var:1:2}
  '3 12 parameter-expansion' # ${var:1:2}
  '4 4 parameter-expansion-delimiter' # {
  '8 8 parameter-expansion-operator' # :
  '10 10 parameter-expansion-operator' # :
  '12 12 parameter-expansion-delimiter' # }
  '14 29 default' # ${var:$off:$len}
  '14 29 parameter-expansion' # ${var:$off:$len}
  '15 15 parameter-expansion-delimiter' # {
  '19 19 parameter-expansion-operator' # :
  '20 23 parameter-expansion' # $off
  '24 24 parameter-expansion-operator' # :
  '25 28 parameter-expansion' # $len
  '29 29 parameter-expansion-delimiter' # }
)
