BUFFER='command FOO=bar env; command -p FOO=bar env'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 15 assign' # FOO=bar
  '13 15 default' # bar
  '17 19 precommand' # env
  '20 20 commandseparator' # ;
  '22 28 precommand' # command
  '30 31 single-hyphen-option' # -p
  '33 39 assign' # FOO=bar
  '37 39 default' # bar
  '41 43 precommand' # env
)
