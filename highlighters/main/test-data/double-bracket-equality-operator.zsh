BUFFER='[[ ${+counters[ok]} == 1 ]]'
unsorted=1

expected_region_highlight=(
  '1 2 reserved-word' # [[
  '4 19 default' # ${+counters[ok]}
  '4 19 parameter-expansion' # ${+counters[ok]}
  '5 5 parameter-expansion-delimiter' # {
  '6 6 parameter-expansion-flag' # +
  '15 18 parameter-expansion-subscript' # [ok]
  '15 15 parameter-expansion-subscript-delimiter' # [
  '18 18 parameter-expansion-subscript-delimiter' # ]
  '19 19 parameter-expansion-delimiter' # }
  '21 22 default' # ==
  '24 24 default' # 1
  '26 27 reserved-word' # ]]
)
