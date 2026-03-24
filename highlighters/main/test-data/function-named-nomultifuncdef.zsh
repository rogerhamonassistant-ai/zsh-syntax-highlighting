unsetopt multifuncdef

BUFFER='f g h () pwd'

expected_region_highlight=(
  '1 1 unknown-token' # f
  '3 3 default' # g
  '5 5 default' # h
  '7 8 reserved-word' # ()
  '10 12 default' # pwd
)
