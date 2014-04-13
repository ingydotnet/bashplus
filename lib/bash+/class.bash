use Bash+ fcopy die

class() {
  local class_name="$1"

  eval "${class_name}__methods=(\$(declare -F | sed 's/^declare -f //' | grep -E \"^$class_name\"))"

  fcopy Class.new Array.new
}

Class.new() {
  local name="$1"
  shift
  eval "$name=( $@ )"
}
