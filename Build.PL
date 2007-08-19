use strict;
use warnings;

use lib qw(lib);
use Histvv::Build;

my $builder = Histvv::Build->new(
    module_name         => 'Histvv',
    dist_name           => 'histvv',
    license             => 'restrictive',
    dist_author         => 'Carsten Milling <cmil@hashtable.de>',
    dist_version        => '0.1',
    build_requires => {
        'Test::More' => 0
    },
    requires =>
    {
     'XML::LibXML'       => 0,
     'XML::LibXSLT'      => 0,
     'Sleepycat::DbXml'  => 2.003
    }
);

$builder->create_build_script();
