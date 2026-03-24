BUFFER='!!= !!:p !!$ !!foo'

expected_region_highlight=(
  '1 3 history-expansion' # !!=
  '5 8 history-expansion' # !!:p
  '10 12 history-expansion' # !!$
  '14 18 history-expansion' # !!foo
)
