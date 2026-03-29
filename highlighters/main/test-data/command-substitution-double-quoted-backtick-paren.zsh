BUFFER=$': $(print "`echo ok` )")'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 24 default' # $(print "`echo ok` )")
  '3 24 command-substitution-unquoted' # $(print "`echo ok` )")
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 9 builtin' # print
  '11 23 default' # "`echo ok` )"
  '11 11 double-quoted-argument' # "
  '21 23 double-quoted-argument' #  )"
  '12 20 back-quoted-argument' # `echo ok`
  '12 12 back-quoted-argument-delimiter' # `
  '13 16 builtin' # echo
  '18 19 default' # ok
  '20 20 back-quoted-argument-delimiter' # `
  '24 24 command-substitution-delimiter-unquoted' # )
)
