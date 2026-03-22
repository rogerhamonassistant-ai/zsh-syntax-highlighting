alias ll='ls -l'

BUFFER='command -p -v ll; command -p -V if; command -p -v ls; command -p -V zstyle'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -p
  '12 13 single-hyphen-option' # -v
  '15 16 unknown-token' # ll
  '17 17 commandseparator' # ;
  '19 25 precommand' # command
  '27 28 single-hyphen-option' # -p
  '30 31 single-hyphen-option' # -V
  '33 34 unknown-token' # if
  '35 35 commandseparator' # ;
  '37 43 precommand' # command
  '45 46 single-hyphen-option' # -p
  '48 49 single-hyphen-option' # -v
  '51 52 command' # ls
  '53 53 commandseparator' # ;
  '55 61 precommand' # command
  '63 64 single-hyphen-option' # -p
  '66 67 single-hyphen-option' # -V
  '69 74 builtin' # zstyle
)
