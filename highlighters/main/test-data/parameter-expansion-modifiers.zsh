BUFFER=': ${f:h} ${f:t:r} ${f:e}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 8 default' # ${f:h}
  '3 8 parameter-expansion' # ${f:h}
  '4 4 parameter-expansion-delimiter' # {
  '6 7 parameter-expansion-modifier' # :h
  '8 8 parameter-expansion-delimiter' # }
  '10 17 default' # ${f:t:r}
  '10 17 parameter-expansion' # ${f:t:r}
  '11 11 parameter-expansion-delimiter' # {
  '13 14 parameter-expansion-modifier' # :t
  '15 16 parameter-expansion-modifier' # :r
  '17 17 parameter-expansion-delimiter' # }
  '19 24 default' # ${f:e}
  '19 24 parameter-expansion' # ${f:e}
  '20 20 parameter-expansion-delimiter' # {
  '22 23 parameter-expansion-modifier' # :e
  '24 24 parameter-expansion-delimiter' # }
)
