BUFFER=': ${path:/tmp/var}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 18 default' # ${path:/tmp/var}
  '3 18 parameter-expansion' # ${path:/tmp/var}
  '4 4 parameter-expansion-delimiter' # {
  '9 10 parameter-expansion-operator' # :/
  '18 18 parameter-expansion-delimiter' # }
)
