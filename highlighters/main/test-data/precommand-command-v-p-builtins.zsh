PATH=/no/such/dir
cat() { command -p cat -- "$@"; }
sed() { command -p sed -- "$@"; }
paste() { command -p paste -- "$@"; }

BUFFER='command -v -p zstyle; command -V -p zstyle; command -v -p __zsyh_review_missing_cmd__'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 13 single-hyphen-option' # -p
  '15 20 builtin' # zstyle
  '21 21 commandseparator' # ;
  '23 29 precommand' # command
  '31 32 single-hyphen-option' # -V
  '34 35 single-hyphen-option' # -p
  '37 42 builtin' # zstyle
  '43 43 commandseparator' # ;
  '45 51 precommand' # command
  '53 54 single-hyphen-option' # -v
  '56 57 single-hyphen-option' # -p
  '59 85 unknown-token' # __zsyh_review_missing_cmd__
)
