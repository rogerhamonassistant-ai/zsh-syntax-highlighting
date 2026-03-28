BUFFER=$': $(echo case in)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # $(echo case in)
  '3 17 command-substitution-unquoted' # $(echo case in)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 builtin' # echo
  '10 13 default' # case
  '15 16 default' # in
  '17 17 command-substitution-delimiter-unquoted' # )
)
