BUFFER=$': $(cat <<-\'EOF\'\n\t)\nEOF\n)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 25 default' # $(cat <<-'EOF'\n\t)\nEOF\n)
  '3 25 command-substitution-unquoted' # $(cat <<-'EOF'\n\t)\nEOF\n)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 7 command' # cat
  '9 11 redirection' # <<-
  '12 16 default' # 'EOF'
  '12 16 single-quoted-argument' # 'EOF'
  '17 17 commandseparator' # \n
  '25 25 command-substitution-delimiter-unquoted' # )
)
