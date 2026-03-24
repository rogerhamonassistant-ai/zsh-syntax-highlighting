BUFFER='env sudo -u root id'

expected_region_highlight=(
  '1 3 precommand' # env
  '5 8 precommand' # sudo
  '10 11 single-hyphen-option' # -u
  '13 16 default' # root
  '18 19 command' # id
)
