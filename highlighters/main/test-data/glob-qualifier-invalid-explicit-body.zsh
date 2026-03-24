setopt bareglobqual extendedglob
BUFFER=': path(#q123) path(#qabc) path(#qN)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 13 default' # path(#q123)
  '15 25 default' # path(#qabc)
  '27 35 default' # path(#qN)
  '31 35 glob-qualifier' # (#qN)
  '31 31 glob-qualifier-delimiter' # (
  '32 33 glob-qualifier-flag' # #q
  '35 35 glob-qualifier-delimiter' # )
)
