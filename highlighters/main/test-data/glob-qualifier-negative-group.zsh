BUFFER=': foo(bar)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 default' # foo(bar)
)
