BUFFER=': ${foo${bar}} ${foo$(print bar)} ${${:-foo}} ${$(print foo)}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${foo${bar}}
  '3 13 unknown-token' # ${foo${bar}}
  '16 33 unknown-token' # ${foo$(print bar)}
  '35 45 default' # ${${:-foo}}
  '35 45 parameter-expansion' # ${${:-foo}}
  '36 36 parameter-expansion-delimiter' # {
  '37 44 parameter-expansion' # ${:-foo}
  '38 38 parameter-expansion-delimiter' # {
  '39 40 parameter-expansion-operator' # :-
  '44 44 parameter-expansion-delimiter' # }
  '45 45 parameter-expansion-delimiter' # }
  '47 61 default' # ${$(print foo)}
  '47 61 parameter-expansion' # ${$(print foo)}
  '48 48 parameter-expansion-delimiter' # {
  '49 60 command-substitution-unquoted' # $(print foo)
  '49 50 command-substitution-delimiter-unquoted' # $(
  '51 55 builtin' # print
  '57 59 default' # foo
  '60 60 command-substitution-delimiter-unquoted' # )
  '61 61 parameter-expansion-delimiter' # }
)
