BUFFER=$': $(cat <<\'EOF\'\n)\nEOF\n)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 23 default' # $(cat <<'EOF'\n)\nEOF\n)
  '3 23 command-substitution-unquoted' # $(cat <<'EOF'\n)\nEOF\n)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 7 command' # cat
  '9 10 redirection' # <<
  '11 15 default' # 'EOF'
  '11 15 single-quoted-argument' # 'EOF'
  '16 16 commandseparator' # \n
  '23 23 command-substitution-delimiter-unquoted' # )
)
