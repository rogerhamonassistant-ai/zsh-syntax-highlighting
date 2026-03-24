BUFFER='function foo () :'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '14 15 reserved-word' # ()
  '17 17 builtin' # :
)
