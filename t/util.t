#!perl -T

use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
    # we want Histvv::Util to provide XML::LibXML to its user; so
    # let's make sure everything works without XML::LibXML being use'd
    ok(! defined $INC{'XML/LibXML.pm'}, 'XML::LibXML not loaded');
	use_ok( 'Histvv::Util' );
}

can_ok('Histvv::Util', 'set_attribute');

my @set_attribute_tests = (

    {
        title => 'basic',
        args  => {
            select => '/foo/*',
            name   => 'qux',
            value  => 23
        },
        xml    => q{<foo><bar/><baz/></foo>},
        expect => q{<foo><bar qux="23"/><baz qux="23"/></foo>},
    },

    {
        title => 'automatic histvv namespace',
        args  => {
            select => '//v:bar',
            name   => 'qux',
            value  => 23
        },
        xml    => qq{<foo xmlns:v="$Histvv::XMLNS"><v:bar/></foo>},
        expect => qq{<foo xmlns:v="$Histvv::XMLNS"><v:bar qux="23"/></foo>}
    },

    {
        title => 'custom namespace',
        args  => {
            select => '//z:bar',
            name   => 'qux',
            value  => 23,
            ns     => { z => 'http://example.org/baz' }
        },
        xml    => q{<foo><bar xmlns="http://example.org/baz"/></foo>},
        expect => q{<foo><bar xmlns="http://example.org/baz" qux="23"/></foo>}
    }

);

my $xp = XML::LibXML->new();

foreach my $t (@set_attribute_tests) {
    my $dom    = $xp->parse_string( $t->{xml} );
    my $expect = $xp->parse_string( $t->{expect} );
    $dom = Histvv::Util::set_attribute( doc => $dom, %{ $t->{args} } );
    is_deeply( $dom->toString(1), $expect->toString(1),
        "set_attribute(): $t->{title}" );
}
