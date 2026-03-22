unsorted=1
WIDGET=zle-line-finish

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=

BUFFER='echo `print "("` `print ")"`'

expected_region_highlight=(
  '14 14 bracket-error' # (
  '26 26 bracket-error' # )
)
