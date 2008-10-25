package Histvv::Util;

use warnings;
use strict;

use Histvv;
use XML::LibXML;

=head1 NAME

Histvv::Util - Histvv utility methods

=head1 VERSION

Version 0.05

=cut

our $VERSION = '0.05';

=head1 SYNOPSIS

    use Histvv::Util;

=head1 DESCRIPTION

This module provides the following utility methods for the Histvv
project:

=head2 set_attribute

  $dom = Histvv::Util::set_attribute(doc  => $dom,  select => $xpath,
                                     name => $name, value  => $value,
                                     ns   => {
                                       foo => 'http://example.org/foo',
                                       bar => 'http://example.com/bar'
                                     }
  );

  ($dom, @nodes) = Histvv::Util::set_attribute( %args );

This method sets an attribute $name with the value $value in the
XML::LibXML::Node $dom for the elements selected by $xpath.

By default the method registers the the namespace prefix C<v> for the
Histvv namespace ($Histvv::XMLNS), so that it can be used in XPath
expressions without further prerequisites. Additional namespace
prefixes can be added by passing a hash reference with prefixes being
the keys and the respective namespace URIs being the values.

In scalar context the method returns the modified DOM object, whereas
in list context the nodes matched by the XPath expression are also
returned.

=cut

sub set_attribute {
    my %args = @_;
    for (qw/doc select name value/) {
        die "Missing argument '$_'!" unless defined $args{$_};
    }
    die "Argument 'doc' is not an XML::LibXML::Node object!"
      unless $args{doc}->isa('XML::LibXML::Node');

    my %ns = defined $args{ns} ? %{$args{ns}} : ();
    $ns{v} = $Histvv::XMLNS unless defined $ns{v};

    # register namespace(s)
    require XML::LibXML::XPathContext;
    my $xc = XML::LibXML::XPathContext->new( $args{doc} );
    for (keys %ns) {
        $xc->registerNs($_, $ns{$_});
    }

    my (@nodes, $cnt);
    eval { @nodes = $xc->findnodes($args{select}) };
    die $@ if $@;

    foreach my $n (@nodes) {
        unless ($n->nodeType == XML_ELEMENT_NODE) {
            warn "Skipping non element node\n";
            next;
        }
        $n->setAttribute($args{name}, $args{value});
        $cnt++;
    }

    wantarray ? ($args{doc}, @nodes) : $args{doc};
}

=head1 SEE ALSO

L<Histvv>, L<XML::LibXML::XPathContext>

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
