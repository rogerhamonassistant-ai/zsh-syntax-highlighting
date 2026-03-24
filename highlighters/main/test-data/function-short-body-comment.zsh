setopt interactivecomments

BUFFER=$'function foo (); # note\n:\nfoo () # note\n:\nfoo ()\n# note\n:'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 12 function' # foo
  '14 15 reserved-word' # ()
  '16 16 commandseparator' # ;
  '18 23 comment' # # note
  '24 24 commandseparator' # newline
  '25 25 builtin' # :
  '26 26 commandseparator' # newline
  '27 29 function' # foo
  '31 32 reserved-word' # ()
  '34 39 comment' # # note
  '40 40 commandseparator' # newline
  '41 41 builtin' # :
  '42 42 commandseparator' # newline
  '43 45 function' # foo
  '47 48 reserved-word' # ()
  '49 49 commandseparator' # newline
  '50 55 comment' # # note
  '56 56 commandseparator' # newline
  '57 57 builtin' # :
)
