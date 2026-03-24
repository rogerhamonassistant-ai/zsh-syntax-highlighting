unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "$(print "it'\''s (ok)")"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "21 21 bracket-level-1" # (
  "24 24 bracket-level-1" # )
  "26 26 bracket-level-1" # )
)
