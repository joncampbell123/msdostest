#!/bin/bash
x=$RANDOM
x=$((($x%1000)+1))

# NTS: For the time being, I want to test oldest first
x=1

suffix=
csuffix=
if [[ "$1" == "svn" ]]; then csuffix=".svn"; suffix="svn"; fi
if [[ "$1" == "xdos" ]]; then csuffix=".xdos"; suffix="xdos"; fi
if [[ "$1" == "qemu" ]]; then csuffix=".qemu"; suffix="qemu"; fi
if [[ "$1" == "svndos" ]]; then csuffix=".svndos"; suffix="svndos"; fi
if [[ "$1" == "svnbochs" ]]; then csuffix=".svnbochs"; suffix="svnbochs"; fi

if [[ !( -f "pick-one$csuffix.cache" ) ]]; then ./yet-to-test.pl $suffix >/dev/null; fi

mode=head

if [[ "$mode" == "head" ]]; then
    ./yet-to-test.pl $suffix | head -n $x | tail -n 1
fi
if [[ "$mode" == "tail" ]]; then
    ./yet-to-test.pl $suffix | tail -n $x | tail -n 1
fi

