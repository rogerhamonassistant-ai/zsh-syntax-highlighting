BUFFER=$'echo `print \x5c\x22(\x5c\x22`'

expected_region_highlight=(
  '15 15 bracket-error' # (
)
