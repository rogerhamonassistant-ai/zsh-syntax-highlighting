setopt multifuncdef

BUFFER='f g h () pwd'

expected_region_highlight=(
  '1 1 function' # f
  '3 3 function' # g
  '5 5 function' # h
  '7 8 reserved-word' # ()
  '10 12 builtin' # pwd
)
