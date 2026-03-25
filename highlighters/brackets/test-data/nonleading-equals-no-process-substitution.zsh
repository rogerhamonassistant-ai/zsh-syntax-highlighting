unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo x=(print "(") ")"'

expected_region_highlight=(
  '8 8 bracket-level-1'
  '18 18 bracket-level-1'
)
