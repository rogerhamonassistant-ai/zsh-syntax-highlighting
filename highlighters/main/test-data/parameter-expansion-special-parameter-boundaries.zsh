BUFFER=': ${?foo} ${-foo} ${#?:-x} ${#?%x} ${#?/a/b} ${#-:+x}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # ${?foo}
  '3 9 unknown-token' # ${?foo}
  '11 17 default' # ${-foo}
  '11 17 unknown-token' # ${-foo}
  '19 26 default' # ${#?:-x}
  '19 26 parameter-expansion' # ${#?:-x}
  '20 20 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-operator' # #
  '26 26 parameter-expansion-delimiter' # }
  '28 34 default' # ${#?%x}
  '28 34 parameter-expansion' # ${#?%x}
  '29 29 parameter-expansion-delimiter' # {
  '30 30 parameter-expansion-operator' # #
  '34 34 parameter-expansion-delimiter' # }
  '36 44 default' # ${#?/a/b}
  '36 44 parameter-expansion' # ${#?/a/b}
  '37 37 parameter-expansion-delimiter' # {
  '38 38 parameter-expansion-operator' # #
  '44 44 parameter-expansion-delimiter' # }
  '46 53 default' # ${#-:+x}
  '46 53 parameter-expansion' # ${#-:+x}
  '47 47 parameter-expansion-delimiter' # {
  '48 48 parameter-expansion-operator' # #
  '53 53 parameter-expansion-delimiter' # }
)
