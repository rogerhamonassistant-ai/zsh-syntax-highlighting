BUFFER='unset BAR; echo ${BAR::=FOO} ${} $BAR ${BAR} "$BAR" "${BAR}"'

expected_region_highlight=(
  '1 5 builtin' # unset
  '7 9 default' # BAR
  '10 10 commandseparator' # ;
  '12 15 builtin' # echo
  '17 28 default' # ${BAR::=FOO}
  '17 28 parameter-expansion' # ${BAR::=FOO}
  '18 18 parameter-expansion-delimiter' # {
  '22 24 parameter-expansion-operator' # ::=
  '28 28 parameter-expansion-delimiter' # }
  '30 32 default' # ${}
  '30 32 parameter-expansion' # ${}
  '31 31 parameter-expansion-delimiter' # {
  '32 32 parameter-expansion-delimiter' # }
  '34 37 default' # $BAR
  '34 37 parameter-expansion' # $BAR
  '39 44 default' # ${BAR}
  '39 44 parameter-expansion' # ${BAR}
  '40 40 parameter-expansion-delimiter' # {
  '44 44 parameter-expansion-delimiter' # }
  '46 51 default' # "$BAR"
  '46 51 double-quoted-argument' # "$BAR"
  '47 50 dollar-double-quoted-argument' # $BAR
  '53 60 default' # "${BAR}"
  '53 60 double-quoted-argument' # "${BAR}"
  '54 59 dollar-double-quoted-argument' # ${BAR}
)
