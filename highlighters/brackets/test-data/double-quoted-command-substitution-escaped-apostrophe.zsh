unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER=$'echo "$(print it\\\'s (ok))"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "21 21 bracket-level-2" # (
  "24 24 bracket-level-2" # )
  "25 25 bracket-level-1" # )
)
