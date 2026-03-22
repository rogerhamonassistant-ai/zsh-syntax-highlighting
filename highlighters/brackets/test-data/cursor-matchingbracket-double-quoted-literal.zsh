BUFFER='echo "()"'
CURSOR=6
WIDGET=zle-keymap-select

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

expected_region_highlight=(
  '7 7 bracket-level-1' # (
  '8 8 bracket-level-1' # )
)
