package Histvv::CLI;

use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;

=head1 NAME

Histvv::CLI - Commandline interface for Histvv tools

=head1 VERSION

Version 0.12

=cut

use version; our $VERSION = qv('0.12');

=head1 SYNOPSIS

  use Histvv::CLI;

  $cli = Histvv::CLI->new();

  # specify custom options
  $cli->add_opts('foo|f' => 0, 'bar|b=s' => 'baz');
  %opts = $cli->get_opts;

  # specify and get options in a single step
  %opts = $cli->get_opts('foo|f' => 0, 'bar|b=s' => 'baz');

  # give feedback
  $cli->say( "doing something..." );
  $cli->chatter( "doing this and that..." );

  # signal a usage error
  $cli->error( $message );

=head1 DESCRIPTION

The I<Histvv::CLI> class is an abstraction layer above L<Getopt::Long>
and L<Pod::Usage> to minimize the effort for individual Histvv
commandline tools to set up their options and give consistent usage
feedback.

I<Histvv::CLI> provides the following features:

=over

=item *

A set of L</"Common Options"> used by all Histvv commandline tools is
automatically configured.

=item *

Basic usage errors (e.g. misspelled or incomplete options provided by
the user) are automatically handled by L</get_opts>.

=item *

Usage instructions are automatically issued by L</get_opts> when
requested by the respective L</"Common Options">. For this to work,
individual programs need to provide sufficient inline documentation
(see L</POD SKELETON> below).

=item *

Convenience methods (see L</error>).

=back

=head2 Common Options

All commandline tools using I<Histvv::CLI> will automatically
have the following options configured:

=over

=item B<--help>, B<-h>

This is the most basic flag that all Histvv commandline tools should
provide. I<Histvv::CLI> automatically takes care to print the
appropriate usage instructions if this flag is set on the commandline
(see L</get_opts>).

=item B<--verbose>, B<-v>

Most programs need to regulate the verbosity of their output which is
traditionally achieved by the B<-v> flag. With I<Histvv::CLI> the flag is
configured so that multiple occurences of B<-v> on the commandline
increase the verbosity level. In addition, when used together with
B<--help>, I<Histvv::CLI> automatically prints the entire manpage of the
program.

=item B<--man>

This is a convenience option to display the entire manpage of the
program. It has the same effect as B<-h -v>.

=back

=cut

my %common_opts = (
                   help    => ['help|h|?', 0],
                   man     => ['man', 0],
                   verbose => ['verbose|v+', 0],
                  );

=head1 METHODS

=head2 new

  $cli = Histvv::CLI->new()

The constructor creates a I<Histvv::CLI> object and sets up the basic
option configuration. When called without arguments only the L</"Common
Options"> are configured.

To configure additional predefined options several flags can be passed
to the constructor like this:

  $cli = Histvv::CLI->new(with_debug => 1)

The following flags are recognized:

=over

=item C<with_debug>

add a B<--debug> option

=back

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    my $self = bless {}, $class;

    my @optconf = ();
    push @optconf, (%common_opts) unless $args{nocommon};
    push @optconf, (debug => ['debug+', 0]) if $args{with_debug};

    $self->{_conf} = { @optconf };

    return $self;
}

=head2 get_opts

  $opts = $cli->get_opts()
  %opts = $cli->get_opts()
  %opts = $cli->get_opts('file|f=s' => undef)

This method parses the commandline arguments (using L<Getopt::Long>)
and sets up the program options as a key/value representation which
can be accessed from the hash reference C<< $cli->{opts} >>.

The method optionally accepts a list of arguments that provide custom
option specifications. See L</add_opts> for details.

Unless C<get_opts> aborts the program, the method returns a hash
reference when called in scalar context. In list context the options
are returned as a list of key/value pairs.

When L</get_opts> notices a failure from L<Getopt::Long> it prints a
usage message and exits.

When the B<--help> or B<--man> flags were set on the commandline
C<get_opts> issues the respective usage instructions (see L</"Common
Options">) and exits the program.

=cut

sub get_opts {
    my $self = shift;

    $self->add_opts(@_) if @_;

    # make Getopt::Long case senitive
    Getopt::Long::Configure  qw(no_ignore_case);

    my (@conf, %opts);

    foreach (keys %{$self->{_conf}}) {
        push @conf, $self->{_conf}{$_}[0] || $_;
        $opts{$_} = $self->{_conf}{$_}[1];
    }

    GetOptions(\%opts, @conf) || pod2usage(2);

    pod2usage(-verbose => 2) if $opts{help} && $opts{verbose};
    pod2usage(-verbose => 2) if $opts{man};
    pod2usage(-verbose => 1) if $opts{help};

    $opts{verbose}++ if $opts{debug};

    $self->{opts} = \%opts;

    return wantarray ? %opts : $self->{opts};
}

=head2 add_opts

  $cli->add_opts('file|f=s' => undef, 'quiet' => 0)

Add custom commandline options for your program. This method
interprets its arguments as a hash where the keys represent option
specifications for L<Getopt::Long> and the values provide the option
defaults.

For convenience you may also pass the same arguments to L</get_opts>
directly which then uses C<add_opts> to configure the options
appropriately.

=cut

sub add_opts {
    my $self = shift;
    my %args = @_;
    foreach (keys %args) {
        my ($name, $spec);
        if (/^([a-zA-Z0-9_]+)/) {
            $name = $1;
            $spec = $_;
            $self->{_conf}{$name} = [$spec, $args{$_}]
              unless defined $self->{_conf}{$name};
        } else {
            warn "Invalid option specification '$_'.\n";
        }
    }
}

=head2 say

  $cli->say( $message )
  $cli->say( $message, $no_newline )

Print a message to standard output. This method takes care to append a
newline to the message unless you explicitly ask not to.

=cut

sub say {
    my $self = shift;
    my $message = shift;
    my $nonewline = shift || 0;
    print $message;
    print "\n" unless $nonewline;
}

=head2 chatter

  $cli->chatter( $message )
  $cli->chatter( $message, $no_newline )

Does the same as L<say> when verbose mode has been requested with the
B<--verbose> switch. Otherwise it remains silent.

=cut

sub chatter {
    my $self = shift;
    my $message = shift;
    my $nonewline = shift || 0;
    $self->say($message, $nonewline) if $self->{opts}{verbose};
}

=head2 debug

  $cli->debug( $message )
  $cli->debug( $message, $no_newline )

Print $message to STDERR when debug mode has been requested
with the B<--debug> switch. Otherwise remain silent.

=cut

sub debug {
    my $self = shift;
    my $message = shift;
    my $nonewline = shift || 0;
    if ($self->{opts}{debug}) {
        print STDERR $message;
        print STDERR "\n" unless $nonewline;
    }
}

=head2 error

  $cli->error( $message )

Use this method to signal usage errors, e.g. inconsistent or missing
commandline options from the user. The $message is passed to
L<pod2usage|Pod::Usage> which prints it together with usage
instructions from the program's documentation and exits the program.

Note: this method is not meant to handle internal or system
errors. Use C<die> or equivalent functions to catch these.

=cut

sub error {
    my $self = shift;
    my $message = shift;
    pod2usage($message);
}

=head1 POD SKELETON

The commandline tools using I<Histvv::CLI> should include at least the
below POD skeleton to facilitate the self-documentation features
provided via L<Pod::Usage>.

  =head1 NAME

  progname - short description

  =head1 SYNOPSIS

   progname custom options ...
   progname --help
   progname --man

  =head1 DESCRIPTION

  Detailed description ...

  =head1 OPTIONS

  =over

  =item B<--verbose>, B<-v>

  Verbose output.

  =item B<--help>, B<-h>

  Display short help message and exit. If used together with B<-v> the
  entire manpage will be displayed.

  =item B<--man>

  Display manpage and exit. This is equivalent to B<-h> B<-v>.

  =back

=head1 TODO

Currently the Histvv::CLI object is fully operational only after
get_opts() has been called. That's weird! We should better pass the
option configuration to the constructor and call GetOptions() at
instantiation time. We would need to remove add_opts() from the public
API because it wouldn't make sense any more.

=head1 SEE ALSO

L<Getopt::Long>, L<Pod::Usage>, L<Histvv>

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
