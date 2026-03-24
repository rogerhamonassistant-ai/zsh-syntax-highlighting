BUFFER=': foo(a|b)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 default' # foo(a|b)
)
