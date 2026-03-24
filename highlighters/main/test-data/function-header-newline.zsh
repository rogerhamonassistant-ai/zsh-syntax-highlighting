BUFFER=$'function foo\n() { :; }\nfunction bar\n{ :; }'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '13 13 commandseparator' # newline
  '14 15 reserved-word' # ()
  '17 17 reserved-word' # {
  '19 19 builtin' # :
  '20 20 commandseparator' # ;
  '22 22 reserved-word' # }
  '23 23 commandseparator' # newline
  '24 31 reserved-word' # function
  '33 35 function' # bar
  '36 36 commandseparator' # newline
  '37 37 reserved-word' # {
  '39 39 builtin' # :
  '40 40 commandseparator' # ;
  '42 42 reserved-word' # }
)
