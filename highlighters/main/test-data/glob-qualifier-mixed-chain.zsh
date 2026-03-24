setopt extendedglob bareglobqual

BUFFER=': *(#q*)(.)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 11 default' # *(#q*)(.)
  '3 3 globbing' # *
  '4 8 glob-qualifier' # (#q*)
  '4 4 glob-qualifier-delimiter' # (
  '5 6 glob-qualifier-flag' # #q
  '7 7 globbing' # *
  '8 8 glob-qualifier-delimiter' # )
  '9 11 glob-qualifier' # (.)
  '9 9 glob-qualifier-delimiter' # (
  '11 11 glob-qualifier-delimiter' # )
)
