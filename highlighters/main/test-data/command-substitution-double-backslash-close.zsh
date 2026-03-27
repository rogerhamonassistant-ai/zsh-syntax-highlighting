BUFFER=$': $(echo \\\\)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 12 default' # $(echo \\)
  '3 12 command-substitution-unquoted' # $(echo \\)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 builtin' # echo
  '10 11 default' # \\
  '12 12 command-substitution-delimiter-unquoted' # )
)
