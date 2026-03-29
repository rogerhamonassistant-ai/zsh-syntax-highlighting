BUFFER='echo $#foo $#1 $#_ $?foo $$foo'

expected_region_highlight=(
  '1 4 builtin' # echo
  '6 10 default' # $#foo
  '6 10 parameter-expansion' # $#foo
  '12 14 default' # $#1
  '12 14 parameter-expansion' # $#1
  '16 18 default' # $#_
  '16 18 parameter-expansion' # $#_
  '20 24 default' # $?foo
  '20 21 parameter-expansion' # $?
  '26 30 default' # $$foo
  '26 27 parameter-expansion' # $$
)
