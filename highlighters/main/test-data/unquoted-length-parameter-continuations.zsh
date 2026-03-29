BUFFER='echo $#foo $#1 $#12 $#123 $#? $#* $#@ $#- $#$ $#$foo $#$$ $#$$foo $#1foo $#12foo $#?foo $#*foo $#@foo $#-foo $#_foo $?foo $$foo'

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
  '43 45 default' # $#$
  '43 45 parameter-expansion' # $#$
  '47 52 default' # $#$foo
  '47 49 parameter-expansion' # $#$
  '54 57 default' # $#$$
  '54 56 parameter-expansion' # $#$
  '59 65 default' # $#$$foo
  '59 61 parameter-expansion' # $#$
  '62 65 parameter-expansion' # $foo
  '67 72 default' # $#1foo
  '67 69 parameter-expansion' # $#1
  '74 80 default' # $#12foo
  '74 77 parameter-expansion' # $#12
  '82 87 default' # $#?foo
  '82 84 parameter-expansion' # $#?
  '89 94 default' # $#*foo
  '89 91 parameter-expansion' # $#*
  '96 101 default' # $#@foo
  '96 98 parameter-expansion' # $#@
  '103 108 default' # $#-foo
  '103 105 parameter-expansion' # $#-
  '110 115 default' # $#_foo
  '110 115 parameter-expansion' # $#_foo
  '117 121 default' # $?foo
  '117 118 parameter-expansion' # $?
  '123 127 default' # $$foo
  '123 124 parameter-expansion' # $$
)
