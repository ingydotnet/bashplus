# bash+ - Modern Bash Programming
#
# Copyright (c) 2013-2020 Ingy döt Net

{
  bash+:version-check() {
    if test "$1" -ge 5; then return; fi
    if test "$1" -eq 4 && test "$2" -ge 4; then return; fi

    echo "The 'bashplus' library requires that 'Bash 4.4+' is installed." >&2
    echo "It doesn't need to be your shell, but it must be in your PATH." >&2
    if [[ ${OSTYPE-} == darwin* ]]; then
      echo "You appear to be on macOS." >&2
      echo "Try: 'brew install bash'." >&2
      echo "This will not change your user shell, it just installs 'Bash 5.x'." >&2
    fi
    exit 1
  }
  bash+:version-check "${BASH_VERSINFO[@]}"
  unset -f Bash:version-check
}

set -e -u -o pipefail

[[ ${BASHPLUS_VERSION-} ]] && return 0

BASHPLUS_VERSION=0.0.9

@() { echo "$@"; }
bash+:export:std() { @ use die warn; }

# Source a bash library call import on it:
bash+:use() {
  local library_name=${1:?bash+:use requires library name}; shift
  local library_path=; library_path=$(bash+:findlib "$library_name") || true
  [[ $library_path ]] ||
    bash+:die "Can't find library '$library_name'." 1

  source "$library_path"
  if bash+:can "$library_name:import"; then
    "$library_name:import" "$@"
  else
    bash+:import "$@"
  fi
}

# Copy bash+: functions to unprefixed functions
bash+:import() {
  local arg=
  for arg; do
    if [[ $arg =~ ^: ]]; then
      # Word splitting required here
      # shellcheck disable=2046
      bash+:import $(bash+:export"$arg")
    else
      bash+:fcopy "bash+:$arg" "$arg"
    fi
  done
}

# Function copy
bash+:fcopy() {
  bash+:can "${1:?bash+:fcopy requires an input function name}" ||
    bash+:die "'$1' is not a function" 2
  local func
  func=$(type "$1" 3>/dev/null | tail -n+3)
  [[ ${3-} ]] && "$3"
  eval "${2:?bash+:fcopy requires an output function name}() $func"
}

# Find the path of a library
bash+:findlib() {
  local library_name
  library_name=$(tr '[:upper:]' '[:lower:]' <<< "${1//:://}").bash
  local lib=${BASHPLUSLIB:-${BASHLIB:-$PATH}}
  library_name=${library_name//+/\\+}
  readarray -d':' -t libs < <(echo -n "$lib")
  find "${libs[@]}" -name "${library_name##*/}" 2>/dev/null |
    grep -E "$library_name\$" |
    head -n1
}

bash+:die() {
  local msg=${1:-Died}
  msg=${msg//\\n/$'\n'}

  printf "%s" "$msg" >&2
  if [[ $msg == *$'\n' ]]; then
    exit 1
  else
    printf "\n"
  fi

  local c
  readarray -d' ' -t c < <(caller "${DIE_STACK_LEVEL:-${2:-0}}" | tr -d '\n')
  if (( ${#c[@]} == 2 )); then
    msg=" at line %d of %s"
  else
    msg=" at line %d in %s of %s"
  fi

  # shellcheck disable=2059
  printf "$msg\n" "${c[@]}" >&2
  exit 1
}

bash+:warn() {
  local msg=${1:-Warning}
  printf "%s" "${msg//\\n/$'\n'}\n" >&2
}

bash+:can() {
  [[ $(type -t "${1:?bash+:can requires a function name}") == function ]]
}
