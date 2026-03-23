setopt bareglobqual

BUFFER=': *(o+:REPLY=\):)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # *(o+:REPLY=\):)
  '3 3 globbing' # *
  '4 17 glob-qualifier' # (o+:REPLY=\):)
  '4 4 glob-qualifier-delimiter' # (
  '17 17 glob-qualifier-delimiter' # )
)
