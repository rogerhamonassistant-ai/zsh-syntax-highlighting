setopt interactivecomments

BUFFER=$': $(echo ok # c\ncase foo\nin a) :;; esac)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 40 default' # $(echo ok # c\ncase foo\nin a) :;; esac)
  '3 40 command-substitution-unquoted' # $(echo ok # c\ncase foo\nin a) :;; esac)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 builtin' # echo
  '10 11 default' # ok
  '13 15 comment' # # c
  '16 16 commandseparator' # \n
  '17 20 reserved-word' # case
  '22 24 default' # foo
  '25 25 commandseparator' # \n
  '26 27 unknown-token' # in
  '29 29 default' # a
)
