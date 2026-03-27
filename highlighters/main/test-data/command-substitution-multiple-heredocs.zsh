BUFFER=$': $(cat <<A <<B\n)\nA\n)\nB\n)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 25 default' # $(cat <<A <<B\n)\nA\n)\nB\n)
  '3 25 command-substitution-unquoted' # $(cat <<A <<B\n)\nA\n)\nB\n)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 7 command' # cat
  '9 10 redirection' # <<
  '11 11 default' # A
  '13 14 redirection' # <<
  '15 15 default' # B
  '16 16 commandseparator' # \n
  '25 25 command-substitution-delimiter-unquoted' # )
)
