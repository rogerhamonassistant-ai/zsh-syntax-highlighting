setopt interactivecomments

BUFFER=$'command -v # note\nls'

expected_region_highlight=(
  '1 7 precommand' # command
  '9 10 single-hyphen-option' # -v
  '12 17 comment' # # note
  '18 18 commandseparator' # newline
  '19 20 command' # ls
)
