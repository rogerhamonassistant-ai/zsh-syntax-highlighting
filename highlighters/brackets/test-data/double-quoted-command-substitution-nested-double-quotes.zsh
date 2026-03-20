unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=

BUFFER='echo "$(print "$(echo "it'\''s (ok)")")"'

expected_region_highlight=(
  "8 8 bracket-level-1" # (
  "17 17 bracket-level-2" # (
  "29 29 bracket-level-3" # (
  "32 32 bracket-level-3" # )
  "34 34 bracket-level-2" # )
  "36 36 bracket-level-1" # )
)
