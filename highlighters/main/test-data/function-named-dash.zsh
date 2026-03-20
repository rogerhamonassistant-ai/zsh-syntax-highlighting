BUFFER='my-func() pwd'

expected_region_highlight=(
  '1 7 function' # my-func
  '8 9 reserved-word' # ()
  '11 13 builtin' # pwd
)
