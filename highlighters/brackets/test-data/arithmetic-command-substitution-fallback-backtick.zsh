unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER=': $((print `echo )))`); (print "("))'

expected_region_highlight=(
  '4 4 bracket-level-1' # (
  '5 5 bracket-level-2' # (
  '18 18 bracket-level-2' # )
  '19 19 bracket-level-1' # )
  '20 20 bracket-error' # )
  '22 22 bracket-error' # )
  '25 25 bracket-level-1' # (
  '33 33 bracket-error' # (
  '35 35 bracket-level-1' # )
  '36 36 bracket-error' # )
)
