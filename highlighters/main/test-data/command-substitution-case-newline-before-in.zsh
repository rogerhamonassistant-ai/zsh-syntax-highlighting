BUFFER=$': $(case foo\nin a) :;; esac)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 28 default' # $(case foo\nin a) :;; esac)
  '3 28 command-substitution-unquoted' # $(case foo\nin a) :;; esac)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 reserved-word' # case
  '10 12 default' # foo
  '13 13 commandseparator' # \n
  '14 15 unknown-token' # in
  '17 17 default' # a
)
