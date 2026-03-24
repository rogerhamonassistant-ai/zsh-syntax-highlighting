BUFFER='command -v -p ls; command -v -V ls'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 13 single-hyphen-option' # -p
  '15 16 command' # ls
  '17 17 commandseparator' # ;
  '19 25 precommand' # command
  '27 28 single-hyphen-option' # -v
  '30 31 single-hyphen-option' # -V
  '33 34 command' # ls
)
