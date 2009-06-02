package Histvv::Db;

use warnings;
use strict;

use File::Basename;
use Sleepycat::DbXml 'simple';

=head1 NAME

Histvv::Db - Dbxml interface

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 SYNOPSIS

  $db = Histvv::Db->new( $file );
  $result  = $db->query( $xquery );

=head1 DESCRIPTION

This module provides a simple interface to the C<dbxml> database.

=head1 METHODS

=head2 new

Create Histvv::Db object. This constructor expects the path to the
database file as argument.

  $db = Histvv::Db->new( $file )
  $db = Histvv::Db->new( $file, { create => 1 } )

=cut

sub new {
    my $class = shift;
    my $file = shift || die 'Missing argument $file';
    my $opts = shift || {};

    die "database '$file' does not exist\n"
      unless -f $file || $opts->{create};

    my $self = {};

    $self->{name} = basename($file);
    $self->{path} = dirname($file);

    my $env_flags =
      Db::DB_CREATE | Db::DB_INIT_MPOOL | Db::DB_INIT_LOCK;
    $env_flags |= Db::DB_PRIVATE if $opts->{private};

    my $env;
    eval {
        $env = new DbEnv(0);
        $env->set_cachesize( 0, 64 * 1024 * 1024, 1 );
        $env->open( $self->{path}, $env_flags, 0 );
    };
    if ( my $e = catch std::exception ) {
        die "Cannot create environment!\n", $e->what, "\n";
    }
    elsif ($@) {
        die "Cannot create environment!\n", $@, "\n";
    }

    eval { $self->{mgr} = new XmlManager($env) };
    if ( my $e = catch XmlException ) {
        die "Cannot create XmlManager!\n", $e->what, "\n";
    }
    elsif ($@) {
        die "Cannot create XmlManager!\n", $@, "\n";
    }

    my $flag = $opts->{create} ? Db::DB_CREATE : 0;
    eval {
        $self->{container} =
          $self->{mgr}->openContainer(  $self->{name}, $flag );
    };
    if ( my $e = catch XmlException ) {
        die "Cannot open container!\n", $e->what, "\n";
    }

    my $uri = 'dbxml:/'. $self->{container}->getName;

    eval {
        $self->{context} = $self->{mgr}->createQueryContext();
        $self->{context}->setDefaultCollection($uri);
    };
    if ( my $e = catch XmlException ) {
        die "Error creating query context!\n", $e->what, "\n";
    }

    bless $self, $class;
}

=head2 query

Run a query and obtain an C<XmlResults> object.

  $results  = $db->query( $xquery );

=cut

sub query {
    my $self   = shift;
    my $xquery = shift;

    my $results;
    eval { $results = $self->{mgr}->query($xquery, $self->{context}) };
    if ( my $e = catch std::exception ) {
        warn "Query failed\n";
        warn $e->what(), "\n";
    }
    elsif ($@) {
        warn "Query failed\n";
        warn $@;
    }

    return $results;
}

=head2 query_all

Run a query and return a list of all results.

  @results  = $db->query_all( $xquery );

=cut

sub query_all {
    my $self   = shift;
    my $xquery = shift;

    my $results = $self->query($xquery);
    my @results;

    eval {
        my $value;
        push @results, $value while $results->next($value);
    };
    if ( my $e = catch std::exception ) {
        warn "Query failed\n";
        warn $e->what(), "\n";
    }
    elsif ($@) {
        warn "Query failed\n";
        warn $@;
    }

    return @results;
}

=head2 add_index

  $db->add_index($nsuri, $name, $spec);

=cut

sub add_index {
    my ($self, $uri, $name, $spec) = @_;
    my $uc = $self->{mgr}->createUpdateContext();
    eval {
        $self->{container}->addIndex($uri, $name, $spec, $uc);
    };
    if ( my $e = catch std::exception ) {
        die $e->what();
    }
    elsif ($@) {
        die $@;
    }
    1;
}

=head2 put_doc

  $ok = $db->put_doc($xml, $name);

=cut

sub put_doc {
    my ($self, $xml, $name) = @_;

    my $uc = $self->{mgr}->createUpdateContext();

    eval {
        $self->{container}->putDocument($name, $xml, $uc);
    };
    if ( my $e = catch std::exception ) {
        die $e->what();
    } elsif ($@) {
        die $@;
    }
    1;
}

=head2 put_files

  $n = $db->put_files(@files);

=cut

sub put_files {
    my $self = shift;
    my $n = 0;
    foreach my $file (@_) {
        my $name = basename($file);
        my $xml = '';
        open F, $file or die $!;
        $xml .= $_ while (<F>);
        close F;
        $self->put_doc($xml, $name) && $n++;
    }
    $n;
}

=head2 delete_doc

  $ok = $db->delete_doc($name);

=cut

sub delete_doc {
    my ($self, $name) = @_;

    my $uc = $self->{mgr}->createUpdateContext();
    my $doc = $self->{container}->getDocument($name);
    return 0 unless $doc;

    eval {
        $self->{container}->deleteDocument($name, $uc);
    };
    if ( my $e = catch std::exception ) {
        die $e->what();
    } elsif ($@) {
        die $@;
    }
    1;
}

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007,2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
