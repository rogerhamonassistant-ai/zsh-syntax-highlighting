BUFFER=': ${*foo*} ${$bar}'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 unknown-token' # ${*foo*}
  '12 18 unknown-token' # ${$bar}
)
