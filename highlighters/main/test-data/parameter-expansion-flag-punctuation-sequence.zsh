BUFFER=': ${(q%q%q)var}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 15 default' # ${(q%q%q)var}
  '3 15 parameter-expansion' # ${(q%q%q)var}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 10 parameter-expansion-flag' # q%q%q
  '11 11 parameter-expansion-delimiter' # )
  '15 15 parameter-expansion-delimiter' # }
)
