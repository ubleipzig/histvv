#!perl -T

use Test::More tests => 1;

use File::Spec;
use File::Temp;

BEGIN {
	use_ok( 'Histvv::Apache' );
}
