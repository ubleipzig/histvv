#!perl -T

use Test::More tests => 2;

use File::Spec;
use File::Temp;

my $DEBUG = $ENV{TEST_DEBUG} || 0;

my $test_dir = File::Temp::tempdir('histvv-XXXXXX', TMPDIR => 0,
                                   CLEANUP => $DEBUG ? 0 : 1 );
my $test_db = File::Spec->catfile($test_dir, 'test.dbxml');

BEGIN {
	use_ok( 'Histvv::Db' );
}

my $db = Histvv::Db->new($test_db, { create => 1, private => 1 });
isa_ok($db, 'Histvv::Db');
