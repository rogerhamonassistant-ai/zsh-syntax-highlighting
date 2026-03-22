unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=': $(( $(print "(") ))'

expected_region_highlight=(
  '4 4 bracket-error' # (
  '5 5 bracket-error' # (
  '8 8 bracket-level-1' # (
  '16 16 bracket-error' # (
  '18 18 bracket-level-1' # )
  '20 20 bracket-error' # )
  '21 21 bracket-error' # )
)
