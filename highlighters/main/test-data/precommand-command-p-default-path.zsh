setopt posixbuiltins
PATH=/no/such/dir
cat() { command -p cat -- "$@"; }
sed() { command -p sed -- "$@"; }
paste() { command -p paste -- "$@"; }

BUFFER='command -p zstyle; command -v -p zstyle; command -p ls; command -v -p ls'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -p
  '12 17 builtin' # zstyle
  '18 18 commandseparator' # ;
  '20 26 precommand' # command
  '28 29 single-hyphen-option' # -v
  '31 32 single-hyphen-option' # -p
  '34 39 builtin' # zstyle
  '40 40 commandseparator' # ;
  '42 48 precommand' # command
  '50 51 single-hyphen-option' # -p
  '53 54 command' # ls
  '55 55 commandseparator' # ;
  '57 63 precommand' # command
  '65 66 single-hyphen-option' # -v
  '68 69 single-hyphen-option' # -p
  '71 72 command' # ls
)
