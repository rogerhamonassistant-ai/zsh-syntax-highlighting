BUFFER=': ${(j[,:])array} ${(s{::})text}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # ${(j[,:])array}
  '3 17 parameter-expansion' # ${(j[,:])array}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 10 parameter-expansion-flag' # j[,:]
  '11 11 parameter-expansion-delimiter' # )
  '17 17 parameter-expansion-delimiter' # }
  '19 32 default' # ${(s{::})text}
  '19 32 parameter-expansion' # ${(s{::})text}
  '20 20 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-delimiter' # (
  '22 26 parameter-expansion-flag' # s{::}
  '27 27 parameter-expansion-delimiter' # )
  '32 32 parameter-expansion-delimiter' # }
)
