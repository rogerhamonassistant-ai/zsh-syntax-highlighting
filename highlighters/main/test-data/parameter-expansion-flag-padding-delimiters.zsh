BUFFER=': ${(l:5::):)foo} ${(r{5}{)}{x})foo}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 17 default' # ${(l:5::):)foo}
  '3 17 parameter-expansion' # ${(l:5::):)foo}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 12 parameter-expansion-flag' # l:5::):
  '13 13 parameter-expansion-delimiter' # )
  '17 17 parameter-expansion-delimiter' # }
  '19 36 default' # ${(r{5}{)}{x})foo}
  '19 36 parameter-expansion' # ${(r{5}{)}{x})foo}
  '20 20 parameter-expansion-delimiter' # {
  '21 21 parameter-expansion-delimiter' # (
  '22 31 parameter-expansion-flag' # r{5}{)}{x}
  '32 32 parameter-expansion-delimiter' # )
  '36 36 parameter-expansion-delimiter' # }
)
