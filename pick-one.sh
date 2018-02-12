#!/bin/bash
x=$RANDOM
x=$((($x%1000)+1))

# NTS: For the time being, I want to test oldest first
x=1

suffix=
csuffix=
if [[ "$1" == "svn" ]]; then csuffix=".svn"; suffix="svn"; fi

if [[ !( -f "pick-one$csuffix.cache" ) ]]; then ./yet-to-test.pl $suffix >/dev/null; fi

./yet-to-test.pl $suffix | head -n $x | tail -n 1

