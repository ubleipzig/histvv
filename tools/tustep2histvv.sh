#!/bin/bash

usage="Usage: tustep2histvv.sh vorlesungen.xml [semester]"

data=$1

if [ -z "$data" ]; then
    echo "$usage"
    exit 1
fi

if [ -n "$2" ]; then
    semesters=$2
else
    semesters=`grep -Po '<semester jahr="[^"]+' $data | sed -e 's/<semester jahr="//'`
fi

path=`dirname $0`
xsl="$path/tustep2histvv.xsl"

files=""

for s in $semesters; do
    y=`echo $s | sed -e 's/\/[0-9][0-9]$//'`
    if [ $s == $y ]; then
        name="${y}s"
    else
        name="${y}w"
    fi

    file="$name.xml"
    files="$files $file"

    echo "$s > $file"
    xsltproc --stringparam semester $s $xsl $data > $file
done

perl -pi -e 's/(vide p. [0-9]+) \[s\. Nr\. ([0-9]+)f+\.\]/<siehe ref="v-$2">$1<\/siehe>/' $files

xmltool indent -v -s $path/../histvv.rng $files
for f in $files; do
    rm -v $f.BAK
done
