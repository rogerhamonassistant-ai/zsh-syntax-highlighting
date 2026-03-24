BUFFER=': ${-[1]} ${?[-1]} ${-:1} ${?:h}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # ${-[1]}
  '3 9 parameter-expansion' # ${-[1]}
  '4 4 parameter-expansion-delimiter' # {
  '6 8 parameter-expansion-subscript' # [1]
  '6 6 parameter-expansion-subscript-delimiter' # [
  '8 8 parameter-expansion-subscript-delimiter' # ]
  '9 9 parameter-expansion-delimiter' # }
  '11 18 default' # ${?[-1]}
  '11 18 parameter-expansion' # ${?[-1]}
  '12 12 parameter-expansion-delimiter' # {
  '14 17 parameter-expansion-subscript' # [-1]
  '14 14 parameter-expansion-subscript-delimiter' # [
  '17 17 parameter-expansion-subscript-delimiter' # ]
  '18 18 parameter-expansion-delimiter' # }
  '20 25 default' # ${-:1}
  '20 25 parameter-expansion' # ${-:1}
  '21 21 parameter-expansion-delimiter' # {
  '23 23 parameter-expansion-operator' # :
  '25 25 parameter-expansion-delimiter' # }
  '27 32 default' # ${?:h}
  '27 32 parameter-expansion' # ${?:h}
  '28 28 parameter-expansion-delimiter' # {
  '30 31 parameter-expansion-modifier' # :h
  '32 32 parameter-expansion-delimiter' # }
)
