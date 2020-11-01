#!/usr/bin/env bash

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+

if ! command -v shellcheck >/dev/null; then
  plan skip_all "The 'shellcheck' utility is not installed"
fi
if [[ ! $(shellcheck --version) =~ 0\.7\.1 ]]; then
  plan skip_all "This test wants shellcheck version 0.7.1"
fi

IFS=$'\n' read -d '' -r -a shell_files <<< "$(
  find bin -type f
  find lib -type f
  echo test/test.bash
  find test -name '*.t'
)" || true

skips=(
  # We want to keep these 2 here always:
  SC1090  # Can't follow non-constant source. Use a directive to specify location.
  SC1091  # Not following: bash+ was not specified as input (see shellcheck -x).
  # These are errors/warnings we can fix one at a time:
  SC2219 # Instead of 'let expr', prefer (( expr ))
  SC2015 # Note that A && B || C is not if-then-else. C may run when A is true
  SC2019 # Use '[:upper:]' to support accents and foreign alphabets.
  SC2018 # Use '[:lower:]' to support accents and foreign alphabets.
  SC2059 # Don't use variables in the printf format string. Use printf '..%s..' "$foo"
  SC2034 # BASHLIB appears unused. Verify use (or export if used externally)
  SC2154 # Foo__Bar_VERSION is referenced but not assigned.
)

skip=$(IFS=,; echo "${skips[*]}")

for file in "${shell_files[@]}"; do
  [[ $file == *swp ]] && continue
  is "$(shellcheck -e "$skip" "$file")" "" \
    "The shell file '$file' passes shellcheck"
done

done_testing

# vim: set ft=sh:
