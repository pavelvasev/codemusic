#/bin/bash

echo parser tests

# this dostn stop on fail
#find . -type f -name "test.rb" -exec sh -c 'echo ================== {}; ruby {}' \;

shopt -s globstar
set -e
for x in tests/**/test.sh; do
  echo "================== $x"
  "$x"
done

echo "ALL FINISHED OK!"