local -a sudo_words
sudo_words=(sudo "")
sudo(){}

BUFFER='$sudo_words -u phy1729 echo'

expected_region_highlight=(
  '1 11 precommand' # $sudo_words
  '13 14 single-hyphen-option' # -u
  '16 22 default' # phy1729
  '24 27 command' # echo
)
