unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER='echo "$(print "()")"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "16 16 bracket-level-2" # (
  "17 17 bracket-level-2" # )
  "19 19 bracket-level-1" # )
)
