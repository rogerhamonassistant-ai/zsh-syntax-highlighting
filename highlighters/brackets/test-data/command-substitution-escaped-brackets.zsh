unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo $(print \() $(print \))'

expected_region_highlight=(
  '7 7 bracket-level-1'
  '16 16 bracket-level-1'
  '28 28 bracket-level-1'
  '19 19 bracket-level-1'
)
