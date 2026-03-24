unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo `print <(echo "(") ")"`'

expected_region_highlight=(
  '14 14 bracket-level-1' # (
  '21 21 bracket-error' # (
  '23 23 bracket-level-1' # )
  '26 26 bracket-error' # )
)
