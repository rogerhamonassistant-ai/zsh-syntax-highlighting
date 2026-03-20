BUFFER='command -v echo; command -V zstyle'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 15 builtin' # echo
  '16 16 commandseparator' # ;
  '18 24 precommand' # command
  '26 27 single-hyphen-option' # -V
  '29 34 builtin' # zstyle
)
