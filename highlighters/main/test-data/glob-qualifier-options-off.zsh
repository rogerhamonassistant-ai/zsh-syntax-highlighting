unsetopt bareglobqual extendedglob

BUFFER=': foo(N) path(#qN)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 8 default' # foo(N)
  '10 18 default' # path(#qN)
)
