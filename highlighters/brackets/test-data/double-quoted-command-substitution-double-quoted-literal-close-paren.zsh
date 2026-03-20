unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "$(print ")")"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "16 16 bracket-error" # )
  "18 18 bracket-level-1" # )
)
