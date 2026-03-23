BUFFER=': ${+name} "${=scalar}"'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 default' # ${+name}
  '3 10 parameter-expansion' # ${+name}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-flag' # +
  '10 10 parameter-expansion-delimiter' # }
  '12 23 default' # "${=scalar}"
  '12 23 double-quoted-argument' # "${=scalar}"
  '13 22 parameter-expansion' # ${=scalar}
  '14 14 parameter-expansion-delimiter' # {
  '15 15 parameter-expansion-flag' # =
  '22 22 parameter-expansion-delimiter' # }
)
