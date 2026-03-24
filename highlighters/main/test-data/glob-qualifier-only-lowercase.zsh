BUFFER=': foo(om) foo(mh-1)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # foo(om)
  '6 9 glob-qualifier' # (om)
  '6 6 glob-qualifier-delimiter' # (
  '9 9 glob-qualifier-delimiter' # )
  '11 19 default' # foo(mh-1)
  '14 19 glob-qualifier' # (mh-1)
  '14 14 glob-qualifier-delimiter' # (
  '19 19 glob-qualifier-delimiter' # )
)
