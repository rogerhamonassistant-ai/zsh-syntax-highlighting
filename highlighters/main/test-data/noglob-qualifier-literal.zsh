BUFFER='noglob foo(N) path(#qN)'

expected_region_highlight=(
  '1 6 precommand' # noglob
  '8 13 unknown-token' # foo(N)
  '15 23 default' # path(#qN)
)
