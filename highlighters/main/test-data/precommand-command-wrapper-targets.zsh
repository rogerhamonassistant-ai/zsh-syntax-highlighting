BUFFER='command env FOO=bar printenv FOO; command sudo -u root id'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 11 precommand' # env
  '13 19 assign' # FOO=bar
  '17 19 default' # bar
  '21 28 command' # printenv
  '30 32 default' # FOO
  '33 33 commandseparator' # ;
  '35 41 precommand' # command
  '43 46 precommand' # sudo
  '48 49 single-hyphen-option' # -u
  '51 54 default' # root
  '56 57 command' # id
)
