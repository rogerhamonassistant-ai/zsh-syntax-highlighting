BUFFER=': ${(j:foo)bar:)arr}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 20 default' # ${(j:foo)bar:)arr}
  '3 20 parameter-expansion' # ${(j:foo)bar:)arr}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 15 parameter-expansion-flag' # j:foo)bar:
  '16 16 parameter-expansion-delimiter' # )
  '20 20 parameter-expansion-delimiter' # }
)
