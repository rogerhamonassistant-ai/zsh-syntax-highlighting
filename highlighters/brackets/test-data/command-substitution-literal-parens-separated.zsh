unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER=': $(print "("); (print ")")'

expected_region_highlight=(
  '4 4 bracket-level-1' # (
  '12 12 bracket-error' # (
  '14 14 bracket-level-1' # )
  '17 17 bracket-level-1' # (
  '25 25 bracket-level-1' # )
  '27 27 bracket-error' # )
)
