setopt bareglobqual

BUFFER=': *(e:REPLY=\\):) *(u:root:) *(g:staff:) *(f:gu+w,o-rx:)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # *(e:REPLY=\\):)
  '3 3 globbing' # *
  '4 17 glob-qualifier' # (e:REPLY=\\):)
  '4 4 glob-qualifier-delimiter' # (
  '17 17 glob-qualifier-delimiter' # )
  '19 28 default' # *(u:root:)
  '19 19 globbing' # *
  '20 28 glob-qualifier' # (u:root:)
  '20 20 glob-qualifier-delimiter' # (
  '28 28 glob-qualifier-delimiter' # )
  '30 40 default' # *(g:staff:)
  '30 30 globbing' # *
  '31 40 glob-qualifier' # (g:staff:)
  '31 31 glob-qualifier-delimiter' # (
  '40 40 glob-qualifier-delimiter' # )
  '42 56 default' # *(f:gu+w,o-rx:)
  '42 42 globbing' # *
  '43 56 glob-qualifier' # (f:gu+w,o-rx:)
  '43 43 glob-qualifier-delimiter' # (
  '56 56 glob-qualifier-delimiter' # )
)
