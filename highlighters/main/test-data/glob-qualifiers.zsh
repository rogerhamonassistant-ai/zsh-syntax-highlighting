BUFFER=': *(.) *.zsh(#qN)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 6 default' # *(.)
  '3 3 globbing' # *
  '4 6 glob-qualifier' # (.)
  '4 4 glob-qualifier-delimiter' # (
  '6 6 glob-qualifier-delimiter' # )
  '8 17 default' # *.zsh(#qN)
  '8 8 globbing' # *
  '13 17 glob-qualifier' # (#qN)
  '13 13 glob-qualifier-delimiter' # (
  '14 15 glob-qualifier-flag' # #q
  '17 17 glob-qualifier-delimiter' # )
)
