BUFFER=': ${?-x} ${??x} ${--x} ${-?x} ${#?-x} ${#??x}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 8 default' # ${?-x}
  '3 8 parameter-expansion' # ${?-x}
  '4 4 parameter-expansion-delimiter' # {
  '6 6 parameter-expansion-operator' # -
  '8 8 parameter-expansion-delimiter' # }
  '10 15 default' # ${??x}
  '10 15 parameter-expansion' # ${??x}
  '11 11 parameter-expansion-delimiter' # {
  '13 13 parameter-expansion-operator' # ?
  '15 15 parameter-expansion-delimiter' # }
  '17 22 default' # ${--x}
  '17 22 parameter-expansion' # ${--x}
  '18 18 parameter-expansion-delimiter' # {
  '20 20 parameter-expansion-operator' # -
  '22 22 parameter-expansion-delimiter' # }
  '24 29 default' # ${-?x}
  '24 29 parameter-expansion' # ${-?x}
  '25 25 parameter-expansion-delimiter' # {
  '27 27 parameter-expansion-operator' # ?
  '29 29 parameter-expansion-delimiter' # }
  '31 37 default' # ${#?-x}
  '31 37 parameter-expansion' # ${#?-x}
  '32 32 parameter-expansion-delimiter' # {
  '33 33 parameter-expansion-operator' # #
  '35 35 parameter-expansion-operator' # -
  '37 37 parameter-expansion-delimiter' # }
  '39 45 default' # ${#??x}
  '39 45 parameter-expansion' # ${#??x}
  '40 40 parameter-expansion-delimiter' # {
  '41 41 parameter-expansion-operator' # #
  '43 43 parameter-expansion-operator' # ?
  '45 45 parameter-expansion-delimiter' # }
)
