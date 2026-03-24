BUFFER=': ${${foo#head}%tail} ${(P)$(print foo)}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 21 default' # ${${foo#head}%tail}
  '3 21 parameter-expansion' # ${${foo#head}%tail}
  '4 4 parameter-expansion-delimiter' # {
  '5 15 parameter-expansion' # ${foo#head}
  '6 6 parameter-expansion-delimiter' # {
  '10 10 parameter-expansion-operator' # #
  '15 15 parameter-expansion-delimiter' # }
  '16 16 parameter-expansion-operator' # %
  '21 21 parameter-expansion-delimiter' # }
  '23 40 default' # ${(P)$(print foo)}
  '23 40 parameter-expansion' # ${(P)$(print foo)}
  '24 24 parameter-expansion-delimiter' # {
  '25 25 parameter-expansion-delimiter' # (
  '26 26 parameter-expansion-flag' # P
  '27 27 parameter-expansion-delimiter' # )
  '28 39 command-substitution-unquoted' # $(print foo)
  '28 29 command-substitution-delimiter-unquoted' # $(
  '30 34 builtin' # print
  '36 38 default' # foo
  '39 39 command-substitution-delimiter-unquoted' # )
  '40 40 parameter-expansion-delimiter' # }
)
