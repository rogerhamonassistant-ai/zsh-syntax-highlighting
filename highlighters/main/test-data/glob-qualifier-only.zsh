setopt extendedglob

BUFFER=': foo(N) path(#qN)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 8 default' # foo(N)
  '6 8 glob-qualifier' # (N)
  '6 6 glob-qualifier-delimiter' # (
  '8 8 glob-qualifier-delimiter' # )
  '10 18 default' # path(#qN)
  '14 18 glob-qualifier' # (#qN)
  '14 14 glob-qualifier-delimiter' # (
  '15 16 glob-qualifier-flag' # #q
  '18 18 glob-qualifier-delimiter' # )
)
