BUFFER='[[ $scalar != foo ]]'
unsorted=1

expected_region_highlight=(
  '1 2 reserved-word' # [[
  '4 10 default' # $scalar
  '12 13 default' # !=
  '15 17 default' # foo
  '19 20 reserved-word' # ]]
)
