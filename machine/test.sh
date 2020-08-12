#/bin/bash

echo machine tests

# this dostn stop on fail
#find . -type f -name "test.rb" -exec sh -c 'echo ================== {}; ruby {}' \;

shopt -s globstar
set -e
for x in tests/**/test.rb; do
  echo "================== $x"
  ruby "$x"
done

echo "ALL FINISHED OK!"