unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo <(print "(") ")"'

expected_region_highlight=(
  '7 7 bracket-level-1' # (
  '15 15 bracket-error' # (
  '17 17 bracket-level-1' # )
  '20 20 bracket-error' # )
)
