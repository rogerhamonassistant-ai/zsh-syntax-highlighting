BUFFER=': ${(@f)lines} ${array[2,4][2]}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${(@f)lines}
  '3 14 parameter-expansion' # ${(@f)lines}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 7 parameter-expansion-flag' # @f
  '8 8 parameter-expansion-delimiter' # )
  '14 14 parameter-expansion-delimiter' # }
  '16 31 default' # ${array[2,4][2]}
  '16 31 parameter-expansion' # ${array[2,4][2]}
  '17 17 parameter-expansion-delimiter' # {
  '23 27 parameter-expansion-subscript' # [2,4]
  '23 23 parameter-expansion-subscript-delimiter' # [
  '27 27 parameter-expansion-subscript-delimiter' # ]
  '28 30 parameter-expansion-subscript' # [2]
  '28 28 parameter-expansion-subscript-delimiter' # [
  '30 30 parameter-expansion-subscript-delimiter' # ]
  '31 31 parameter-expansion-delimiter' # }
)
