BUFFER=': ${path:F:2:h} ${value:W:/:h}'
unsorted=1

expected_region_highlight=(
  '1 1 builtin' # :
  '3 15 default' # ${path:F:2:h}
  '3 15 parameter-expansion' # ${path:F:2:h}
  '4 4 parameter-expansion-delimiter' # {
  '9 14 parameter-expansion-modifier' # :F:2:h
  '15 15 parameter-expansion-delimiter' # }
  '17 30 default' # ${value:W:/:h}
  '17 30 parameter-expansion' # ${value:W:/:h}
  '18 18 parameter-expansion-delimiter' # {
  '24 29 parameter-expansion-modifier' # :W:/:h
  '30 30 parameter-expansion-delimiter' # }
)
