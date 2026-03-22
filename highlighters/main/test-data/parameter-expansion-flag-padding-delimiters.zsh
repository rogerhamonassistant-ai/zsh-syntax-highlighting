BUFFER=': ${(l:5::):)foo} ${(r:5::):)foo}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # ${(l:5::):)foo}
  '3 17 parameter-expansion' # ${(l:5::):)foo}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 10 parameter-expansion-flag' # l:5::
  '11 11 parameter-expansion-delimiter' # )
  '12 16 parameter-expansion-modifier' # :)foo
  '17 17 parameter-expansion-delimiter' # }
  '19 33 default' # ${(r:5::):)foo}
  '19 33 parameter-expansion' # ${(r:5::):)foo}
  '20 20 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-delimiter' # (
  '22 26 parameter-expansion-flag' # r:5::
  '27 27 parameter-expansion-delimiter' # )
  '28 32 parameter-expansion-modifier' # :)foo
  '33 33 parameter-expansion-delimiter' # }
)
