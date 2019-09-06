#!/bin/bash
for i in $*; do
    ./look-for-duplicate.pl "`pwd`" "$i" || exit 1
done

