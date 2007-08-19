package Histvv::Build;

use strict;
use warnings;

=head1 NAME

Histvv::Build - Build class for the Histvv project

=head1 VERSION

$Revision$

$Date$

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

=for comment The documentation for actions cannot be interleaved with
the subroutines since ./Build help <action> cannot handle this.

=over 4

=item xxeconfig

This action bundles the RNG, CSS and template files into a ZIP archive
suitable to be deployed as an add-on for the XMLmind XML Editor.

=back

=cut

# sub ACTION_xxeconfig {
#     my $self = shift;
#     $self->depends_on('build');

#     my @map = (
#         [ 'histvv.rng',       'histvv.rng' ],
#         [ 'histvv.xxe',       'histvv.xxe' ],
#         [ 'histvv.xxe_addon', 'histvv.xxe_addon' ],
#         [ 'css',              'css' ],
#         [ 'templates',        'templates' ],

#     );
# }


=pod

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 SEE ALSO

L<Module::Build>

=head1 COPYRIGHT & LICENSE

Copyright 2007 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
