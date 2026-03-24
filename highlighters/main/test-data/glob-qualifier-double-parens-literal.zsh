BUFFER=': foo((^x))'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 11 default' # foo((^x))
)
