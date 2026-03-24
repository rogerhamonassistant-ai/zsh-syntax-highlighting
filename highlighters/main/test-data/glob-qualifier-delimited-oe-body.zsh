setopt bareglobqual

BUFFER=': *(oe:((1)):)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # *(oe:((1)):)
  '3 3 globbing' # *
  '4 14 glob-qualifier' # (oe:((1)):)
  '4 4 glob-qualifier-delimiter' # (
  '14 14 glob-qualifier-delimiter' # )
)
