PATH=/no/such/dir
cat() { command -p cat -- "$@"; }
sed() { command -p sed -- "$@"; }
paste() { command -p paste -- "$@"; }

alias ll='ls -l'
f() { :; }

BUFFER='command -v -p zstyle; command -V -p zstyle; command -v -p ll; command -V -p f; command -v -p if; command -v -p __zsyh_review_missing_cmd__'

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
  '59 60 unknown-token' # ll
  '61 61 commandseparator' # ;
  '63 69 precommand' # command
  '71 72 single-hyphen-option' # -V
  '74 75 single-hyphen-option' # -p
  '77 77 unknown-token' # f
  '78 78 commandseparator' # ;
  '80 86 precommand' # command
  '88 89 single-hyphen-option' # -v
  '91 92 single-hyphen-option' # -p
  '94 95 unknown-token' # if
  '96 96 commandseparator' # ;
  '98 104 precommand' # command
  '106 107 single-hyphen-option' # -v
  '109 110 single-hyphen-option' # -p
  '112 138 unknown-token' # __zsyh_review_missing_cmd__
)
