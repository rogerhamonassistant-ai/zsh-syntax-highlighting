PATH=/no/such/dir
cat() { command -p cat -- "$@"; }
sed() { command -p sed -- "$@"; }
paste() { command -p paste -- "$@"; }

BUFFER='command -p builtin echo; command -p env FOO=bar true; command -p __zsyh_review_missing_cmd__'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -p
  '12 18 unknown-token' # builtin
  '20 23 default' # echo
  '24 24 commandseparator' # ;
  '26 32 precommand' # command
  '34 35 single-hyphen-option' # -p
  '37 39 precommand' # env
  '41 47 assign' # FOO=bar
  '45 47 default' # bar
  '49 52 unknown-token' # true
  '53 53 commandseparator' # ;
  '55 61 precommand' # command
  '63 64 single-hyphen-option' # -p
  '66 92 unknown-token' # __zsyh_review_missing_cmd__
)
