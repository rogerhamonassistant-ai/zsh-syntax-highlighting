unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER='echo $(print <(echo "(") ")")'

expected_region_highlight=(
  '7 7 bracket-level-1' # (
  '15 15 bracket-level-2' # (
  '22 22 bracket-error' # (
  '24 24 bracket-level-2' # )
  '27 27 bracket-error' # )
  '29 29 bracket-level-1' # )
)
