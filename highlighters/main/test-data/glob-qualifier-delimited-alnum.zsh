setopt bareglobqual

BUFFER=': *(ea((1))a)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 13 default' # *(ea((1))a)
  '3 3 globbing' # *
  '4 13 glob-qualifier' # (ea((1))a)
  '4 4 glob-qualifier-delimiter' # (
  '13 13 glob-qualifier-delimiter' # )
)
