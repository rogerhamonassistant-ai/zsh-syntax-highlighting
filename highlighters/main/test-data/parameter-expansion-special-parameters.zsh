BUFFER=': ${?} ${-} ${#?}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 6 default' # ${?}
  '3 6 parameter-expansion' # ${?}
  '4 4 parameter-expansion-delimiter' # {
  '6 6 parameter-expansion-delimiter' # }
  '8 11 default' # ${-}
  '8 11 parameter-expansion' # ${-}
  '9 9 parameter-expansion-delimiter' # {
  '11 11 parameter-expansion-delimiter' # }
  '13 17 default' # ${#?}
  '13 17 parameter-expansion' # ${#?}
  '14 14 parameter-expansion-delimiter' # {
  '15 15 parameter-expansion-operator' # #
  '17 17 parameter-expansion-delimiter' # }
)
