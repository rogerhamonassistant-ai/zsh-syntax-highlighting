BUFFER='echo "${BAR::=${$(echo -n foo/bar.foo):t:r}}/$(echo -n fox).${BAR}"'

expected_region_highlight=(
  '1 4 builtin' # echo
  '6 67 default' # "${BAR::=${$(echo -n foo/bar.foo):t:r}}/$(echo -n fox).${BAR}"
  '6 6 double-quoted-argument' # "
  '45 45 double-quoted-argument' # /
  '60 67 double-quoted-argument' # .${BAR}"
  '7 14 parameter-expansion' # ${BAR::=
  '44 44 parameter-expansion' # }
  '8 8 parameter-expansion-delimiter' # {
  '12 14 parameter-expansion-operator' # ::=
  '15 16 parameter-expansion' # ${
  '39 43 parameter-expansion' # :t:r}
  '16 16 parameter-expansion-delimiter' # {
  '17 38 command-substitution-quoted' # $(echo -n foo/bar.foo)
  '17 18 command-substitution-delimiter-quoted' # $(
  '19 22 builtin' # echo
  '24 25 single-hyphen-option' # -n
  '27 37 default' # foo/bar.foo
  '38 38 command-substitution-delimiter-quoted' # )
  '39 40 parameter-expansion-modifier' # :t
  '41 42 parameter-expansion-modifier' # :r
  '43 43 parameter-expansion-delimiter' # }
  '44 44 parameter-expansion-delimiter' # }
  '46 59 command-substitution-quoted' # $(echo -n fox)
  '46 47 command-substitution-delimiter-quoted' # $(
  '48 51 builtin' # echo
  '53 54 single-hyphen-option' # -n
  '56 58 default' # fox
  '59 59 command-substitution-delimiter-quoted' # )
  '61 66 dollar-double-quoted-argument' # ${BAR}
)
