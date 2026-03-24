setopt extendedglob bareglobqual

BUFFER=': (*.c|*.h)(N) (*.md~README.md)(N) (*.md~README.md)(#qN)'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # (*.c|*.h)(N)
  '4 4 globbing' # *
  '8 8 globbing' # *
  '12 14 glob-qualifier' # (N)
  '12 12 glob-qualifier-delimiter' # (
  '14 14 glob-qualifier-delimiter' # )
  '16 34 default' # (*.md~README.md)(N)
  '17 17 globbing' # *
  '32 34 glob-qualifier' # (N)
  '32 32 glob-qualifier-delimiter' # (
  '34 34 glob-qualifier-delimiter' # )
  '36 56 default' # (*.md~README.md)(#qN)
  '37 37 globbing' # *
  '52 56 glob-qualifier' # (#qN)
  '52 52 glob-qualifier-delimiter' # (
  '53 54 glob-qualifier-flag' # #q
  '56 56 glob-qualifier-delimiter' # )
)
