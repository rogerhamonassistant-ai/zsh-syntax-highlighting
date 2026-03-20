BUFFER=': foo(-.) foo(^/) *.c(N[1])'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 9 default' # foo(-.)
  '6 9 glob-qualifier' # (-.)
  '6 6 glob-qualifier-delimiter' # (
  '9 9 glob-qualifier-delimiter' # )
  '11 17 default' # foo(^/)
  '14 17 glob-qualifier' # (^/)
  '14 14 glob-qualifier-delimiter' # (
  '17 17 glob-qualifier-delimiter' # )
  '19 27 default' # *.c(N[1])
  '19 19 globbing' # *
  '22 27 glob-qualifier' # (N[1])
  '22 22 glob-qualifier-delimiter' # (
  '27 27 glob-qualifier-delimiter' # )
)
