setopt posixbuiltins

BUFFER='command zstyle; command times; exec zstyle; exec builtin echo'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 14 builtin' # zstyle
  '15 15 commandseparator' # ;
  '17 23 precommand' # command
  '25 29 builtin' # times
  '30 30 commandseparator' # ;
  '32 35 precommand' # exec
  '37 42 unknown-token' # zstyle
  '43 43 commandseparator' # ;
  '45 48 precommand' # exec
  '50 56 unknown-token' # builtin
  '58 61 default' # echo
)
