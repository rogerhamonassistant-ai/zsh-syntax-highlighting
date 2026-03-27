unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER='echo $(print <(echo "(") ")")'

expected_region_highlight=(
  '24 24 bracket-level-2'
  '15 15 bracket-level-2'
  '7 7 bracket-level-1'
  '29 29 bracket-level-1'
)
