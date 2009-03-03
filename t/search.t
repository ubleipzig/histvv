#!perl -T

use strict;
use warnings;

use Test::More tests => 4;

use XML::LibXML;

BEGIN {
	use_ok( 'Histvv::Search' );
}

can_ok('Histvv::Search', 'strip_text');

my $xml = <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<vv xmlns="$Histvv::XMLNS">
  <foo> foo <seite>2</seite>bar</foo>
</vv>
EOF

my $doc = XML::LibXML->new->parse_string($xml);
my ($n) = $doc->getElementsByLocalName('foo');
my $txt = Histvv::Search::strip_text($n);

is($txt, 'foo bar', 'strip_text() yields expected result');
is($doc->toString(1), $xml, 'strip_text() keeps source intact');

#diag($doc->toString());
#diag($txt);
