setopt bareglobqual

BUFFER=': *(P:):)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # *(P:):)
  '3 3 globbing' # *
  '4 9 glob-qualifier' # (P:):)
  '4 4 glob-qualifier-delimiter' # (
  '9 9 glob-qualifier-delimiter' # )
)
