BUFFER='command -v command builtin zstyle'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 18 builtin' # command
  '20 26 builtin' # builtin
  '28 33 builtin' # zstyle
)
