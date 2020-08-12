#!/bin/bash

Q=$(dirname "$(readlink -f "$0")")

cd $Q

../../compile.sh <input.cm >result.txt 2>log.txt

diff result.txt result.txt.need && echo test ok