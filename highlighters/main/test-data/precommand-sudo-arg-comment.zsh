setopt interactivecomments

BUFFER=$'sudo -u root # note\nls'

expected_region_highlight=(
  '1 4 precommand' # sudo
  '6 7 single-hyphen-option' # -u
  '9 12 default' # root
  '14 19 comment' # # note
  '20 20 commandseparator' # newline
  '21 22 command' # ls
)
