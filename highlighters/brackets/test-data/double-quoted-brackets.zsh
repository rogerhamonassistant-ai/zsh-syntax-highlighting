unsorted=1

ZSH_HIGHLIGHT_STYLES[bracket-level-1]=
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=

BUFFER='echo "([]{})"'

expected_region_highlight=(
  "7 7 bracket-level-1" # (
  "8 8 bracket-level-2" # [
  "9 9 bracket-level-2" # ]
  "10 10 bracket-level-2" # {
  "11 11 bracket-level-2" # }
  "12 12 bracket-level-1" # )
)
