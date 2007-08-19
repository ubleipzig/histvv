#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Histvv' );
}

diag( "Testing Histvv $Histvv::VERSION, Perl $], $^X" );
