package Histvv::Search;

use warnings;
use strict;

use Histvv;
use XML::LibXML;
use XML::LibXML::XPathContext;

=head1 NAME

Histvv::Search - Histvv search related methods

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

    use Histvv::Util;

=head1 DESCRIPTION

This module collects some search related methods for the Histvv
project:


=head2 annotate_doc

  $doc = annotate_doc( $doc );

Add attributes to C<veranstaltung> elements in a Histvv document that
facilitate searching.

=cut

sub annotate_doc {
    my $doc = shift;

    my $xc = XML::LibXML::XPathContext->new( $doc );
    $xc->registerNs('v', $Histvv::XMLNS);

    my $vv = $doc->documentElement();

    # semester
    my $jahr = $xc->findvalue('/v:vv/v:kopf/v:beginn/v:jahr');
    my $sem  = $xc->findvalue('/v:vv/v:kopf/v:semester');
    my $semid = $jahr;
    $semid .= $sem eq 'Winter' ? 'w' : 's';
    $vv->setAttribute('x-semester', $semid);

    foreach my $va ($xc->findnodes('//v:veranstaltung')) {

        # thema
        my @themen =
          $xc->findnodes( 'ancestor::v:veranstaltungsgruppe/v:thema | v:thema',
            $va );
        if ( $xc->findnodes( 'v:thema[@kontext]', $va ) || @themen == 0 ) {
            my ($sg) = $xc->findnodes( 'parent::v:sachgruppe/v:titel', $va );
            unshift @themen, $sg if $sg;
        }
        my @thema = map $xc->findvalue( 'normalize-space(.)', $_ ), @themen;

        my $thema = join ' | ', @thema;
        $va->setAttribute( 'x-thema', $thema );

        # text
        my $text = $xc->findvalue( 'normalize-space(.)', $va );
        $text = normalize_chars($text);
        $va->setAttribute( 'x-text', $text );

        # dozent

        # first we look for elements inside <veranstaltung>
        my @dozenten = $xc->findnodes( 'v:dozent | v:ders', $va );

        # if there aren't any we search the containing
        # <veranstaltunsgruppe>
        unless (@dozenten) {
            @dozenten = $xc->findnodes(
                'ancestor::v:veranstaltungsgruppe/v:dozent[last()]', $va );
        }

        my ( @refs, @strings );
        foreach my $d (@dozenten) {

            # capture ref attributes
            if ( my $ref = $xc->findvalue( '@ref', $d ) ) {
                push @refs, $ref;
            }

            # get preceding <dozent> for <ders> elements
            if ( $d->localname eq 'ders' && !$xc->exists( '@ref', $d ) ) {
                my ($pre) = $xc->findnodes( 'preceding::v:dozent[1]', $d );
                $d = $pre if $pre;
            }

            # finally capture literal content
            push @strings, $xc->findvalue( 'normalize-space(v:nachname)', $d )
              unless $d->localname eq 'ders';
        }

        $va->setAttribute( 'x-dozent', join ' ', @refs ) if @refs;
        $va->setAttribute( 'x-dozenten', lc( join '; ', @strings ) )
          if @strings;
    }

    return $doc;
}

sub annotate_file {
    my $doc = XML::LibXML->new->parse_file(shift);
    annotate_doc($doc);
}

sub normalize_chars {
    my $txt = shift;
    $txt = lc $txt;
    $txt =~ s/\x{00e4}/ae/g; # ä
    $txt =~ s/\x{00f6}/oe/g; # ö
    $txt =~ s/\x{00FC}/ue/g; # ü
    $txt;
}

=head1 SEE ALSO

L<Histvv>

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
