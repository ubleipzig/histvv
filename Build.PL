use strict;
use warnings;

use lib qw(lib);
use Histvv::Build;

my $builder = Histvv::Build->new(
    module_name         => 'Histvv',
    dist_name           => 'histvv',
    license             => 'restrictive',
    dist_author         => 'Carsten Milling <cmil@hashtable.de>',
    build_requires => {
        'Module::Build' => 0.36,
        'Test::More' => 0
    },
    requires =>
    {
     'XML::LibXML'       => 1.69,
     'XML::LibXSLT'      => 0,
     'Sleepycat::DbXml'  => 2.0040013,
     'Apache2::Request'  => 0,
     'File::ShareDir'    => 1.00
    },
    recommends => {
        'Config::GitLike' => '1.08',
        'Data::Beacon'    => '0.2.5'
    },

    share_dir => 'share'

);

$builder->create_build_script();
