BUFFER=$': $(case foo in (a) :;; esac)'

expected_region_highlight=(
  '1 1 builtin' # :
  '3 29 default' # $(case foo in (a) :;; esac)
  '3 29 command-substitution-unquoted' # $(case foo in (a) :;; esac)
  '3 4 command-substitution-delimiter-unquoted' # $(
  '5 8 reserved-word' # case
  '10 12 default' # foo
  '14 15 default' # in
  '17 19 default' # (a)
  '21 21 default' # :
  '22 23 default' # ;;
  '25 28 default' # esac
)
