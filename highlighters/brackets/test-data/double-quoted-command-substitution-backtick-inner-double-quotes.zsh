unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "$(print "`echo ")"`")"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "23 23 bracket-error" # )
  "27 27 bracket-level-1" # )
)
