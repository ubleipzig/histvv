#!perl -T

use Test::More tests => 1;

TODO: {
    local $TODO = 'setup Apache::Test';
    use_ok( 'Apache::Histvv' );
}
