BUFFER=$'function foo\n:'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '13 13 commandseparator' # newline
  '14 14 builtin' # :
)
