setopt bareglobqual

BUFFER=': *(+:REPLY=\):)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 16 default' # *(+:REPLY=\):)
  '3 3 globbing' # *
  '4 16 glob-qualifier' # (+:REPLY=\):)
  '4 4 glob-qualifier-delimiter' # (
  '16 16 glob-qualifier-delimiter' # )
)
