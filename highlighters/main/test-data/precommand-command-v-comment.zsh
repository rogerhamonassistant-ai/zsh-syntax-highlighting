setopt interactivecomments
alias ll='ls -l'

BUFFER='command -v ll # comment'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 13 alias' # ll
  '15 23 comment' # # comment
)
