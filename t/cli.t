#!perl -T

use warnings;
use strict;

use Test::More tests => 11;

BEGIN { use_ok( 'Histvv::CLI' ) }

my $debug = 0;

# test public API
can_ok('Histvv::CLI', qw(new add_opts get_opts say chatter error));

# make sure we don't pass any commandline arguments by accident when
# we call the test individually
local @ARGV = ();

my $cli = Histvv::CLI->new();
isa_ok($cli, 'Histvv::CLI', 'cli');

# basic test
{
    my $cli = Histvv::CLI->new();
    my $opts = $cli->get_opts();
    is_deeply({help => 0, man => 0, verbose => 0}, $opts, 'basic options');
    diag(Dumper $opts) if $debug;

    is($opts, $cli->{opts}, 'compare $opts and $cli->{opts}');

    $opts->{verbose} = 3;
    is_deeply($opts, $cli->{opts}, 'manipulate options');
    diag(Dumper $opts, $cli->{opts}) if $debug;
}

# with predefined options
{
    my $opts = Histvv::CLI->new(with_debug => 1)->get_opts();
    is_deeply($opts, {help => 0, man => 0, verbose => 0, debug => 0},
              'with debug option');
    diag(Dumper $opts) if $debug;
}

# test say() and chatter()
{
    use Test::Output;
    my $cli = Histvv::CLI->new;

    my $opts = $cli->get_opts;

    stdout_is { $cli->say("foo") } "foo\n", "test say()";
    stdout_is { $cli->say("foo", 1) } "foo", "test say() with no newline";
    stdout_is { $cli->chatter("blah") } "", "test chatter() non-verbose";
    stdout_is { $cli->say("foo") } "foo\n", "test say()";
}

__END__

=head1 NAME

foo - bar

=head1 SYNOPSIS

  foo --bar [--baz]
  foo --help
  foo --man

=head1 DESCRIPTION

foo does bar

=head1 OPTIONS

=over

=item B<--bar>

make foo do bar

=item B<--baz>

optionally do baz as well

=back

=cut
