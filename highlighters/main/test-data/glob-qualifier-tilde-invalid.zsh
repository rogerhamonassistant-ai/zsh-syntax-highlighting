unsetopt extendedglob

BUFFER=': foo(N~)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # foo(N~)
  '6 9 glob-qualifier' # (N~)
  '6 6 glob-qualifier-delimiter' # (
  '9 9 glob-qualifier-delimiter' # )
)
