BUFFER='env command -V zstyle'

expected_region_highlight=(
  '1 3 precommand' # env
  '5 11 command' # command
  '13 14 single-hyphen-option' # -V
  '16 21 default' # zstyle
)
