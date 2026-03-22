ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

unsorted=1
WIDGET=zle-line-finish

BUFFER=$'echo `print it\x5c\x27s (ok)`'

expected_region_highlight=(
  '19 19 bracket-level-1' # (
  '22 22 bracket-level-1' # )
)
