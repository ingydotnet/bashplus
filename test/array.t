#!/bin/bash -e

source test/test.bash

PATH=$PWD/bin:$PATH
source bash+ use

BASHLIB=test/lib:lib

use Bash+::Array
ok $? 'use Foo::Bar - works'

Array.new foo

done_testing 1
