unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "$(( 1 + ( ))"'

expected_region_highlight=(
  '8 8 bracket-error' # (
  '9 9 bracket-error' # (
  '15 15 bracket-level-1' # (
  '17 17 bracket-level-1' # )
  '18 18 bracket-error' # )
)
