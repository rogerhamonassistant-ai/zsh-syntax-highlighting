unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo `print "(" $(echo `print x`) ")"`'

expected_region_highlight=(
  '14 14 bracket-level-1' # (
  '18 18 bracket-level-1' # (
  '33 33 bracket-level-1' # )
  '36 36 bracket-level-1' # )
)
