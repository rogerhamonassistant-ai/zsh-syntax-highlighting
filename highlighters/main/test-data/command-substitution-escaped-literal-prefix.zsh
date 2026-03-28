BUFFER=$': $(echo \\$(foo)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 16 default' # $(echo \$(foo)
  '3 16 command-substitution-unquoted' # $(echo \$(foo)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 builtin' # echo
  '10 16 default' # \$(foo)
)
