BUFFER=': "${var:-'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 10 default' # "${var:-
  '3 10 double-quoted-argument-unclosed' # "${var:-
  '4 10 parameter-expansion' # ${var:-
  '5 5 parameter-expansion-delimiter' # {
  '9 10 parameter-expansion-operator' # :-
)
