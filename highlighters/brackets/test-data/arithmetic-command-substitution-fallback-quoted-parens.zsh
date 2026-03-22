unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER=': $((print "("); (print ")"))'

expected_region_highlight=(
  '4 4 bracket-level-1' # (
  '5 5 bracket-level-2' # (
  '13 13 bracket-level-1' # (
  '15 15 bracket-level-2' # )
  '18 18 bracket-level-2' # (
  '26 26 bracket-level-1' # )
  '28 28 bracket-level-2' # )
  '29 29 bracket-level-1' # )
)
