BUFFER='env -i FOO=bar printenv FOO; env -u HOME FOO=bar command -v printenv'

expected_region_highlight=(
  '1 3 precommand' # env
  '5 6 single-hyphen-option' # -i
  '8 14 assign' # FOO=bar
  '12 14 default' # bar
  '16 23 command' # printenv
  '25 27 default' # FOO
  '28 28 commandseparator' # ;
  '30 32 precommand' # env
  '34 35 single-hyphen-option' # -u
  '37 40 default' # HOME
  '42 48 assign' # FOO=bar
  '46 48 default' # bar
  '50 56 command' # command
  '58 59 single-hyphen-option' # -v
  '61 68 default' # printenv
)
