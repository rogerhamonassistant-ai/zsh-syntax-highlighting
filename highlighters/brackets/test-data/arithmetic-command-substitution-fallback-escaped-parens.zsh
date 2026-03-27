unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER=': $((print \)); (print "("))'

expected_region_highlight=(
  '4 4 bracket-level-1'
  '5 5 bracket-level-2'
  '14 14 bracket-level-2'
  '27 27 bracket-level-2'
  '28 28 bracket-level-1'
  '17 17 bracket-level-2'
)
