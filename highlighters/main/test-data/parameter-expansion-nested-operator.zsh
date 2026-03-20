BUFFER=': ${name:-${foo:h}}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 19 default' # ${name:-${foo:h}}
  '3 19 parameter-expansion' # ${name:-${foo:h}}
  '4 4 parameter-expansion-delimiter' # {
  '9 10 parameter-expansion-operator' # :-
  '11 18 parameter-expansion' # ${foo:h}
  '12 12 parameter-expansion-delimiter' # {
  '16 17 parameter-expansion-modifier' # :h
  '18 18 parameter-expansion-delimiter' # }
  '19 19 parameter-expansion-delimiter' # }
)
