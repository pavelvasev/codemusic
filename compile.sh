#!/bin/bash

Q=$(dirname "$(readlink -f "$0")")

# echo compiling $Q

$Q/generator/compile.sh
