unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "$(print "(") $(print ")")"'

expected_region_highlight=(
  '8 8 bracket-level-1'
  '18 18 bracket-level-1'
  '31 31 bracket-level-1'
  '21 21 bracket-level-1'
)
