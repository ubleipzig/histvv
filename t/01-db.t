#!perl -T

use Test::More tests => 5;

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

ok(
    $db->add_index(
        'http://histvv.uni-leipzig.de/ns/2007',
        'vv', 'node-element-presence'
    ),
    'add_index() succeeds'
);

ok( $db->put_doc( '<foo>bar</foo>', 'foo.xml' ), 'put_doc()' );

ok( $db->put_files('t/test.xml'), 'put_files()' );
