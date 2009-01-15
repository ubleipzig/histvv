#!/bin/sh

db=/var/www/histvv/db/histvv.dbxml

tmp=`tempfile`

dbxmlquery=`dirname $0`/../bin/dbxml-query

perl -Ilib $dbxmlquery \
  -d $db \
  -q 'declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";
      for $x in collection()/v:vv[v:kopf/v:status/@komplett]//v:thema
      return normalize-space($x)' > $tmp

perl -CiO -nle 'print for split /\P{L}+/' $tmp | sort |uniq

rm $tmp
