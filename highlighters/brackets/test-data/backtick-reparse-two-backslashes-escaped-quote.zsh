unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=$'echo `print \\\\\"(\\\\\" )`'

expected_region_highlight=(
  '16 16 bracket-level-1' # (
  '21 21 bracket-level-1' # )
)
