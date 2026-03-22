unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=$'echo <(print "\\\\()") >(print "\\\\()")'

expected_region_highlight=(
  '7 7 bracket-level-1' # (
  '17 17 bracket-level-1' # (
  '18 18 bracket-level-1' # )
  '20 20 bracket-level-1' # )
  '23 23 bracket-level-1' # (
  '33 33 bracket-level-1' # (
  '34 34 bracket-level-1' # )
  '36 36 bracket-level-1' # )
)
