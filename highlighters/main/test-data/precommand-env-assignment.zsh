BUFFER='env FOO=bar printenv FOO'

expected_region_highlight=(
  '1 3 precommand' # env
  '5 11 assign' # FOO=bar
  '9 11 default' # bar
  '13 20 command' # printenv
  '22 24 default' # FOO
)
