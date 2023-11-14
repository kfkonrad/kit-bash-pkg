kit() {
  local command
  while [ -n "$1" ]; do
    case "$1" in
      -h|--help|-\?|/\?)
        command="help"
        ;;
      -v|--version)
        command="version"
        ;;
      -?*)
        echo "Unknown option: $1" >&2
        return 1
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  case "${@: -1}" in
    -h|--help|-\?|/\?)
      command="help"
      set -- "${@:1:$(($#-1))}"
      ;;
  esac

  if [ -z "$command" ]; then
    if [ -n "$1" ]; then
      command="$1"
      shift
    else
      command="help"
    fi
  fi

  if declare -f "__kit_$command" > /dev/null; then
      "__kit_$command" "$@"
  else
      git "$command" "$@"
  fi
}

__kit_version() {
  echo v0.4.2
}

__kit_help() {
  echo "kit - Kevin's git wrapper"
  echo
  echo 'subcommands:'
  echo '  clone'
  echo '    clone into automatically chosen directory'
  echo '  push'
  echo '    push and set upstream automatically'
  echo '  version'
  echo '    prints version of kit'
  echo '  help'
  echo '    prints this help'
  echo '  *'
  echo '    pass to git'
}

__kit_clone() {
  local url fullpath
  url=$(__kit_helper_get_first_non_option_argument "$@")
  fullpath=$(__kit_helper_extract_full_path "$url")
  mkdir -p "$fullpath"
  git clone "$@" "$fullpath"
  if [ -n "$kit_cd_after_clone" ]; then
    cd "$fullpath"
  fi
}

__kit_helper_get_first_non_option_argument() {
  while [ -n "$1" ]; do
    case "$1" in
      -?*)
        if [ -n "$3" ] && [[ ! $2 =~ ^- ]]; then
          shift 1
        fi
        ;;
      *)
        echo "$1"
        break
        ;;
    esac
    shift
  done
}

__kit_helper_extract_full_path() {
  if echo "$1" | grep -qe "^git@" -e "^ssh://git@"; then
    __kit_helper_extract_full_path_ssh "$1"
  else
    __kit_helper_extract_full_path_https "$1"
  fi
}

__kit_helper_extract_full_path_ssh() {
  local schemaless=$(echo "$1" | sed 's/.*@//;s|:|/|;s|\.git$||')
  __kit_helper_extract_full_path_generic "$schemaless"
}

__kit_helper_extract_full_path_https() {
  local schemaless=$(echo "$1" | sed 's|^https://||;s|\.git$||')
  __kit_helper_extract_full_path_generic "$schemaless"
}

__kit_helper_extract_full_path_generic() {
  local fqdn=$(echo "$1" | sed 's|/.*||')
  local bash_friendly_fqdn=$(echo "$fqdn" | sed 's/[.:-]/_/g')
  local domain_filter
  local path_filter
  local filtered_domain
  local unfiltered_path
  local filtered_path
  local base_dir
  local kit_domain_filter_fqdn=kit_domain_filter_$bash_friendly_fqdn
  local kit_path_filter_fqdn=kit_path_filter_$bash_friendly_fqdn

  if [ "$(eval echo \$$kit_domain_filter_fqdn)" != '$' ]; then
      domain_filter=$(eval echo \$$kit_domain_filter_fqdn)
  elif [ -n "$kit_domain_filter" ]; then
    domain_filter="$kit_domain_filter"
  else
    domain_filter='s|\..*$||'
  fi

  if [ "$(eval echo \$$kit_path_filter_fqdn)" != '$' ]; then
    path_filter=$(eval echo \$$kit_path_filter_fqdn)
  elif [ -n "$kit_path_filter" ]; then
    path_filter="$kit_path_filter"
  else
    path_filter=''
  fi

  filtered_domain=$(echo "$fqdn" | sed "$domain_filter")
  unfiltered_path=$(echo "$1" | sed 's|[^/]*/||')
  filtered_path=$(echo "$unfiltered_path" | sed "$path_filter")

  if [ -n "$kit_base_dir" ]; then
    base_dir="$kit_base_dir"
  else
    base_dir="$HOME/workspace"
  fi

  echo "$base_dir/$filtered_domain/$filtered_path"
}
