setopt bareglobqual
BUFFER=': foo(bar) foo(om)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 default' # foo(bar)
  '12 18 default' # foo(om)
  '15 18 glob-qualifier' # (om)
  '15 15 glob-qualifier-delimiter' # (
  '18 18 glob-qualifier-delimiter' # )
)
