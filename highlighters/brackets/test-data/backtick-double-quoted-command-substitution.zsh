unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=

BUFFER='echo `print "$(echo "it'\''s (ok)")"`'

expected_region_highlight=(
  "15 15 bracket-level-1" # (
  "27 27 bracket-level-1" # (
  "30 30 bracket-level-1" # )
  "32 32 bracket-level-1" # )
)
