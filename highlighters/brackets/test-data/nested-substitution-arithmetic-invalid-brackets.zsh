unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=

BUFFER='echo $(print $(( 1'\''('\''0 )))'

expected_region_highlight=(
  '7 7 bracket-error' # (
  '15 15 bracket-level-2' # (
  '16 16 bracket-level-3' # (
  '20 20 bracket-level-1' # (
  '24 24 bracket-level-1' # )
  '25 25 bracket-level-3' # )
  '26 26 bracket-level-2' # )
)
