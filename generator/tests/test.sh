#/bin/bash

echo elements tests

shopt -s globstar
set -e
for x in */test.sh; do
  echo "================== $x"
  "$x"
done

echo "ALL TESTS OK!"
