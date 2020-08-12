#!/bin/bash

Q=$(dirname "$(readlink -f "$0")")

# echo compiling $Q

ruby $Q/compile.rb
