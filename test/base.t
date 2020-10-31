#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+ :std

# shellcheck disable=2016
ok $? '$(source bash+) works'

# shellcheck disable=2016
is "$BASHPLUS_VERSION" '0.0.9' 'BASHPLUS_VERSION is 0.0.9'

done_testing 2
