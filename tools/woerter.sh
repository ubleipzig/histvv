#!/bin/sh

basex \
  -i histvv \
  'declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";
   for $x in collection()/v:vv[v:kopf/v:status/@komplett]//v:thema
   return tokenize(normalize-space($x), "\P{L}+")' \
  | sort | uniq
