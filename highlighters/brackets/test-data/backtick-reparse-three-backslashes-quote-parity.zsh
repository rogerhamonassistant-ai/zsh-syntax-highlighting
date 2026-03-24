unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=$'echo `print \\\\\\\"(\\\\\\\" )`'

expected_region_highlight=(
  '17 17 bracket-error' # (
  '23 23 bracket-error' # )
)
