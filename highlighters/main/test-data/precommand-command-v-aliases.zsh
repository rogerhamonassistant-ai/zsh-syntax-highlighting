alias ll='ls -l'
alias -g GG='| grep'
alias -s txt=cat

BUFFER='command -v ll GG foo.txt'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 13 alias' # ll
  '15 16 global-alias' # GG
  '18 24 suffix-alias' # foo.txt
)
