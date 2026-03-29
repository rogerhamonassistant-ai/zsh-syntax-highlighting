BUFFER='echo $#foo $#1 $#_ $#? $#* $#@ $#- $?foo $$foo'

expected_region_highlight=(
  '1 4 builtin' # echo
  '6 10 default' # $#foo
  '6 10 parameter-expansion' # $#foo
  '12 14 default' # $#1
  '12 14 parameter-expansion' # $#1
  '16 18 default' # $#_
  '16 18 parameter-expansion' # $#_
  '20 22 default' # $#?
  '20 22 parameter-expansion' # $#?
  '24 26 default' # $#*
  '24 26 parameter-expansion' # $#*
  '28 30 default' # $#@
  '28 30 parameter-expansion' # $#@
  '32 34 default' # $#-
  '32 34 parameter-expansion' # $#-
  '36 40 default' # $?foo
  '36 37 parameter-expansion' # $?
  '42 46 default' # $$foo
  '42 43 parameter-expansion' # $$
)
