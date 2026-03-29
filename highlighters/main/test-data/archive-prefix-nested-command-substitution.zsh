BUFFER=$'git archive \\\n  --format=tar.gz \\\n  --prefix="${repo::=${$(git remote get-url origin):t:r}}/" \\\n  -o "${repo}-${branch::=$(git branch --show-current)}-$(git rev-parse --short "${branch}").tar.gz" \\\n  "${branch}"'

expected_region_highlight=(
  '1 3 command' # git
  '5 11 default' # archive
  '17 31 double-hyphen-option' # --format=tar.gz
  '37 93 double-hyphen-option' # --prefix="${repo::=${$(git remote get-url origin):t:r}}/"
  '46 46 double-quoted-argument' # "
  '92 93 double-quoted-argument' # /"
  '47 55 parameter-expansion' # ${repo::=
  '91 91 parameter-expansion' # }
  '48 48 parameter-expansion-delimiter' # {
  '53 55 parameter-expansion-operator' # ::=
  '56 57 parameter-expansion' # ${
  '86 90 parameter-expansion' # :t:r}
  '57 57 parameter-expansion-delimiter' # {
  '58 85 command-substitution-quoted' # $(git remote get-url origin)
  '58 59 command-substitution-delimiter-quoted' # $(
  '60 62 command' # git
  '64 69 default' # remote
  '71 77 default' # get-url
  '79 84 default' # origin
  '85 85 command-substitution-delimiter-quoted' # )
  '86 87 parameter-expansion-modifier' # :t
  '88 89 parameter-expansion-modifier' # :r
  '90 90 parameter-expansion-delimiter' # }
  '91 91 parameter-expansion-delimiter' # }
  '99 100 single-hyphen-option' # -o
  '102 195 default' # "${repo}-${branch::=$(git branch --show-current)}-$(git rev-parse --short "${branch}").tar.gz"
  '102 110 double-quoted-argument' # "${repo}-
  '151 151 double-quoted-argument' # -
  '188 195 double-quoted-argument' # .tar.gz"
  '103 109 dollar-double-quoted-argument' # ${repo}
  '111 121 parameter-expansion' # ${branch::=
  '150 150 parameter-expansion' # }
  '112 112 parameter-expansion-delimiter' # {
  '119 121 parameter-expansion-operator' # ::=
  '122 149 command-substitution-quoted' # $(git branch --show-current)
  '122 123 command-substitution-delimiter-quoted' # $(
  '124 126 command' # git
  '128 133 default' # branch
  '135 148 double-hyphen-option' # --show-current
  '149 149 command-substitution-delimiter-quoted' # )
  '150 150 parameter-expansion-delimiter' # }
  '152 187 command-substitution-quoted' # $(git rev-parse --short "${branch}")
  '152 153 command-substitution-delimiter-quoted' # $(
  '154 156 command' # git
  '158 166 default' # rev-parse
  '168 174 double-hyphen-option' # --short
  '176 186 default' # "${branch}"
  '176 186 double-quoted-argument' # "${branch}"
  '177 185 dollar-double-quoted-argument' # ${branch}
  '187 187 command-substitution-delimiter-quoted' # )
  '201 211 default' # "${branch}"
  '201 211 double-quoted-argument' # "${branch}"
  '202 210 dollar-double-quoted-argument' # ${branch}
)
