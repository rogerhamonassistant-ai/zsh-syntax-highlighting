BUFFER=$': $(case1 in)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 13 default' # $(case1 in)
  '3 13 command-substitution-unquoted' # $(case1 in)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 9 unknown-token' # case1
  '11 12 default' # in
  '13 13 command-substitution-delimiter-unquoted' # )
)
