unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=

BUFFER='echo `print $(( \( ))`'

expected_region_highlight=(
  '14 14 bracket-error' # (
  '15 15 bracket-level-2' # (
  '18 18 bracket-level-3' # (
  '20 20 bracket-level-3' # )
  '21 21 bracket-level-2' # )
)
