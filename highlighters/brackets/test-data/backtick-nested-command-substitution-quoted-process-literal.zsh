unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo `print $(echo "<(" ) ")"`'

expected_region_highlight=(
  '14 14 bracket-level-1' # (
  '22 22 bracket-error' # (
  '25 25 bracket-level-1' # )
  '28 28 bracket-error' # )
)
