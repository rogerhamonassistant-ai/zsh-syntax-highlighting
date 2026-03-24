unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=$'echo "$(print \\()" $\'(\'' 

expected_region_highlight=(
  '8 8 bracket-level-1' # (
  '16 16 bracket-error' # (
  '17 17 bracket-level-1' # )
)
