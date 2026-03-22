BUFFER='command -v git >/dev/null; command -V ls 2>&1'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 14 command' # git
  '16 16 redirection' # >
  '17 25 path' # /dev/null
  '26 26 commandseparator' # ;
  '28 34 precommand' # command
  '36 37 single-hyphen-option' # -V
  '39 40 command' # ls
  '42 44 redirection' # 2>&
  '45 45 numeric-fd' # 1
)
