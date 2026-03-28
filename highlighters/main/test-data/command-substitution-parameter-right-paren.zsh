BUFFER=$': $(print ${x/)/X})'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 19 default' # $(print ${x/)/X})
  '3 19 command-substitution-unquoted' # $(print ${x/)/X})
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 9 builtin' # print
  '11 18 default' # ${x/)/X}
  '11 18 parameter-expansion' # ${x/)/X}
  '12 12 parameter-expansion-delimiter' # ${
  '14 14 parameter-expansion-operator' # /
  '18 18 parameter-expansion-delimiter' # }
  '19 19 command-substitution-delimiter-unquoted' # )
)
