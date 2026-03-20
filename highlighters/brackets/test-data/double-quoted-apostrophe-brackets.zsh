unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo "it'\''s (ok)"'

expected_region_highlight=(
  "12 12 bracket-level-1" # (
  "15 15 bracket-level-1" # )
)
