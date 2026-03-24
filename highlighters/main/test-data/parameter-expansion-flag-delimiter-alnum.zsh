BUFFER=': ${(ja)a)foo}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 14 default' # ${(ja)a)foo}
  '3 14 parameter-expansion' # ${(ja)a)foo}
  '4 4 parameter-expansion-delimiter' # {
  '5 5 parameter-expansion-delimiter' # (
  '6 9 parameter-expansion-flag' # ja)a
  '10 10 parameter-expansion-delimiter' # )
  '14 14 parameter-expansion-delimiter' # }
)
