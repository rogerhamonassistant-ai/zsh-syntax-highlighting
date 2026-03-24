BUFFER=': ${PATH:s::/:} ${var:gs:/:_:}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 15 default' # ${PATH:s::/:}
  '3 15 parameter-expansion' # ${PATH:s::/:}
  '4 4 parameter-expansion-delimiter' # {
  '9 14 parameter-expansion-modifier' # :s::/: 
  '15 15 parameter-expansion-delimiter' # }
  '17 30 default' # ${var:gs:/:_:}
  '17 30 parameter-expansion' # ${var:gs:/:_:}
  '18 18 parameter-expansion-delimiter' # {
  '22 29 parameter-expansion-modifier' # :gs:/:_:
  '30 30 parameter-expansion-delimiter' # }
)
