BUFFER='function -T my-func { pwd }'

expected_region_highlight=(
  '1 8 reserved-word' # function
  '10 11 single-hyphen-option' # -T
  '13 19 function' # my-func
  '21 21 reserved-word' # {
  '23 25 builtin' # pwd
  '27 27 reserved-word' # }
)
