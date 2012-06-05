package Histvv::Build;

use strict;
use warnings;

=head1 NAME

Histvv::Build - Build class for the Histvv project

=head1 VERSION

Version 0.11

=cut

use version; our $VERSION = qv('0.11');

=head1 SYNOPSIS

  use Histvv::Build;
  $build = Histvv::Build->new(
      # add parameters here
      # see Module::Build
    );

=cut

use base 'Module::Build';

=head1 DESCRIPTION

This module provides the custom methods for the build system of the
L<Histvv> package.

=head1 ACTIONS

=head2 xxeconfig

Creates a ZIP archive suitable to be deployed as add-on for the
XMLmind XML Editor.

=cut

sub ACTION_xxeconfig {
    my $self = shift;
    my $conf_dir = 'histvv_config';
    my $zipfile = "$conf_dir.zip";

    $self->delete_filetree($conf_dir);
    $self->delete_filetree($zipfile);
    $self->log_info("Creating $conf_dir\n");
    $self->add_to_cleanup($conf_dir);

    my $dist_files = $self->_read_manifest('MANIFEST')
      or die "Cannot create xxeconfig without MANIFEST\n";
    my $files = { map { my $from = $_; s/^xxe\///; $from, $_ }
              grep /^xxe\//, keys %$dist_files };
    $files->{'histvv.rng'} = 'histvv.rng';

    foreach my $from (sort keys %$files) {
        my $new = $self->copy_if_modified(
            from    => $from,
            to  => File::Spec->catfile($conf_dir, $files->{$from}),
            verbose => $self->verbose || 0
        );
    }

    $self->log_info("Creating $zipfile\n");
    $self->do_system('zip', '-r', $zipfile, $conf_dir);
    $self->delete_filetree($conf_dir);
}

=head2 versionbump

Changes the version number for each Perl module in the distribution.
The new version number needs to be passed from the command line:

  ./Build versionbump version=0.02

For this action to work properly the version of a module must be
specified in the following way:

  =head1 VERSION

  Version 0.01

  =cut

  use version; our $VERSION = qv('0.01');

NOTE: This action modifies the actual source files and is for
developers only. Therefore it is aborted unless it is run in a git or
subversion working copy.

=cut

sub ACTION_versionbump {
    my $self = shift;

    die "This action only runs in git or subversion working copies!\n"
      unless -d '.git' or -d '.svn';

    my $v = $self->args('version')
      or die "You need to pass a version number!\n";

    require version;
    my $vv = version->new("$v");
    die "Invalid version.\n" if $vv eq 0;

    my $rx = qr{
        ^=head1 \s+ VERSION
        \n\n+
        Version \s+ ([._0-9]+)
        \n\n+
        =cut
        \n\n+
        use \s+ version;
        \s+
        our
        \s+
        \$VERSION \s+ = \s+ qv\('([._0-9]+)'\);
        \n\n+
    }mx;

    my $new = "=head1 VERSION\n\nVersion $v\n\n"
            . "=cut\n\nuse version; our \$VERSION = qv('$v');\n\n";

    foreach my $file (sort keys %{ $self->find_pm_files }) {
        my $code = '';
        open IN, $file or die "Cannot open $file: $!\n";
        $code .= $_ while <IN>;
        close IN;

        if ($code =~ s/$rx/$new/) {
            $self->log_info("Modifying $file\n");
            open OUT, ">$file"  or die "Cannot write to $file: $!\n";
            print OUT $code;
            close OUT;
        } else {
            warn "Cannot find version section in $file.\n";
        }
    }

}

=pod

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 SEE ALSO

L<Module::Build>

=head1 COPYRIGHT & LICENSE

Copyright 2007,2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
