BUFFER=': ${foo ${bar:-'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 15 default' # ${foo ${bar:-
  '3 15 parameter-expansion' # ${foo ${bar:-
  '4 4 parameter-expansion-delimiter' # {
  '9 15 parameter-expansion' # ${bar:-
  '10 10 parameter-expansion-delimiter' # {
  '14 15 parameter-expansion-operator' # :-
)
