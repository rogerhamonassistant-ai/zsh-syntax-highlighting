BUFFER='env zstyle; ssh-agent zstyle; caffeinate zstyle'

expected_region_highlight=(
  '1 3 precommand' # env
  '5 10 unknown-token' # zstyle
  '11 11 commandseparator' # ;
  '13 21 precommand' # ssh-agent
  '23 28 unknown-token' # zstyle
  '29 29 commandseparator' # ;
  '31 40 precommand' # caffeinate
  '42 47 unknown-token' # zstyle
)
