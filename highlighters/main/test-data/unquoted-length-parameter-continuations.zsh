BUFFER='echo $#foo $#1 $#12 $#123 $#? $#* $#@ $#- $#1foo $#12foo $#?foo $#*foo $#@foo $#-foo $#_foo $?foo $$foo'

expected_region_highlight=(
  '1 4 builtin' # echo
  '6 10 default' # $#foo
  '6 10 parameter-expansion' # $#foo
  '12 14 default' # $#1
  '12 14 parameter-expansion' # $#1
  '16 19 default' # $#12
  '16 19 parameter-expansion' # $#12
  '21 25 default' # $#123
  '21 25 parameter-expansion' # $#123
  '27 29 default' # $#?
  '27 29 parameter-expansion' # $#?
  '31 33 default' # $#*
  '31 33 parameter-expansion' # $#*
  '35 37 default' # $#@
  '35 37 parameter-expansion' # $#@
  '39 41 default' # $#-
  '39 41 parameter-expansion' # $#-
  '43 48 default' # $#1foo
  '43 45 parameter-expansion' # $#1
  '50 56 default' # $#12foo
  '50 53 parameter-expansion' # $#12
  '58 63 default' # $#?foo
  '58 60 parameter-expansion' # $#?
  '65 70 default' # $#*foo
  '65 67 parameter-expansion' # $#*
  '72 77 default' # $#@foo
  '72 74 parameter-expansion' # $#@
  '79 84 default' # $#-foo
  '79 81 parameter-expansion' # $#-
  '86 91 default' # $#_foo
  '86 91 parameter-expansion' # $#_foo
  '93 97 default' # $?foo
  '93 94 parameter-expansion' # $?
  '99 103 default' # $$foo
  '99 100 parameter-expansion' # $$
)
