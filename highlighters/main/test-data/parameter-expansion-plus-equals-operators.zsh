BUFFER=': ${name+word} ${name=word}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${name+word}
  '3 14 parameter-expansion' # ${name+word}
  '4 4 parameter-expansion-delimiter' # {
  '9 9 parameter-expansion-operator' # +
  '14 14 parameter-expansion-delimiter' # }
  '16 27 default' # ${name=word}
  '16 27 parameter-expansion' # ${name=word}
  '17 17 parameter-expansion-delimiter' # {
  '22 22 parameter-expansion-operator' # =
  '27 27 parameter-expansion-delimiter' # }
)
