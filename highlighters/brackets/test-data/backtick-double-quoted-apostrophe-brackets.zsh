unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo `print "it'\''s (ok)"`'

expected_region_highlight=(
  "19 19 bracket-level-1" # (
  "22 22 bracket-level-1" # )
)
