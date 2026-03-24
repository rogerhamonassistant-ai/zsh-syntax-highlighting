BUFFER=': ${#} ${#}x ${#?} ${#-}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 6 default' # ${#}
  '3 6 parameter-expansion' # ${#}
  '4 4 parameter-expansion-delimiter' # {
  '6 6 parameter-expansion-delimiter' # }
  '8 12 default' # ${#}x
  '8 11 parameter-expansion' # ${#}
  '9 9 parameter-expansion-delimiter' # {
  '11 11 parameter-expansion-delimiter' # }
  '14 18 default' # ${#?}
  '14 18 parameter-expansion' # ${#?}
  '15 15 parameter-expansion-delimiter' # {
  '16 16 parameter-expansion-operator' # #
  '18 18 parameter-expansion-delimiter' # }
  '20 24 default' # ${#-}
  '20 24 parameter-expansion' # ${#-}
  '21 21 parameter-expansion-delimiter' # {
  '22 22 parameter-expansion-operator' # #
  '24 24 parameter-expansion-delimiter' # }
)
