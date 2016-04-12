package Histvv::Search;

use warnings;
use strict;

use Histvv;
use Histvv::Util;
use XML::LibXML;
use XML::LibXML::XPathContext;

use utf8;

=head1 NAME

Histvv::Search - Histvv search related methods

=head1 VERSION

Version 0.13

=cut

use version; our $VERSION = qv('0.13');

=head1 SYNOPSIS

    use Histvv::Search;

    $xquery = Histvv::Search::build_xquery( %params );


=head1 DESCRIPTION

This module collects some search related methods for the Histvv
project:


=head2 build_xquery

  $query = build_xquery( %params);

Build an XQuery from input parameters. This method expects a list of
named parameters, all of which are optional.

text => $text, dozent => $dozent,
                        von => $semester1, bis => $semester2,
                        fakultaet => $fakultaet

=over

=item text

A search string for full text search.

=item dozent

A search string to search for in C<dozent> elements.

=item fakultaet

One or more faculty IDs separated by space. Possible values are
C<Theologie>, C<Jura>, C<Medizin>, and C<Philosophie>.

=item von

Semester ID for the earliest semester to include.

=item bis

Semester ID for the latest semester to include.

=item start

The offset in the result sequence.

=item interval

Number of results to return.

=back

=cut

my $sem_min = '1814w';
my $sem_max = '1914s';

sub build_xquery {
    my %args = @_;

    my $start =
      $args{start} && $args{start} =~ /^[1-9][0-9]*$/ ? $args{start} : 1;
    my $interval =
         $args{interval}
      && $args{interval} =~ /^[1-9][0-9]*$/ ? $args{interval} : 10;
    $interval = 100 if $interval > 100;

    my @v_predicates;

    my ($text, @text);
    if ($text = $args{text}) {
        utf8::decode($text);
        @text =  _tokenize($text);
    }
    my $text_predicate = join ' and ', map { "contains(\@x-text, '$_')" } @text;
    push @v_predicates, $text_predicate if $text_predicate;

    my ($doz, @doz);
    if ($doz = $args{dozent}) {
        utf8::decode($doz);
        @doz =  _tokenize($doz);
    }
    my $doz_predicate = join ' and ', map { "contains(\@x-dozenten, '$_')" } @doz;
    push @v_predicates, $doz_predicate if $doz_predicate;

    my $v_predicate = join ' and ', @v_predicates;

    my ($von, $bis, @sem);
    if (Histvv::Util::is_semesterid($args{von}) && $args{von} gt $sem_min) {
        $von = $args{von};
        push @sem, "\@x-semester >= '$von'";
    } else {
        $von = $sem_min;
    }
    if (Histvv::Util::is_semesterid($args{bis}) && $args{bis} lt $sem_max) {
        $bis = $args{bis};
        push @sem, "\@x-semester <= '$bis'";
    } else {
        $bis = $sem_max;
    }
    my $sem_predicate = join ' and ', @sem;

    my @fac;
    foreach my $fac (split /\s+/, $args{fakultaet} || '') {
        push @fac, $fac if $fac =~ /^\w+$/;
    }
    #my $fac_predicate = join ' or ', map { "\@fakult\x{00e4}t='$_'" } @fac;
    my $fac_predicate = join ' or ', map { "\@fakultät='$_'" } @fac;

    my $path = 'collection()/v:vv';
    $path .= "[$sem_predicate]"             if @sem;
    $path .= "//v:sachgruppe[$fac_predicate]" if @fac;
    $path .= '//v:veranstaltung';
    $path .= "[$v_predicate]"               if @v_predicates;

    my $vars = <<'EOT';
let $start := %d
let $interval := %d
let $text := "%s"
let $dozent := "%s"
let $fakultaet := "%s"
let $von := "%s"
let $bis := "%s"
EOT

    $vars = sprintf $vars,
      map ( { Histvv::Util::xquery_escape( $_ || '' ) } $start,
        $interval, $text, $doz, $args{fakultaet}, $von, $bis );

    my $query = <<EOT;
declare namespace v = "$Histvv::XMLNS";

$vars

let \$stellen := $path
EOT

    $query .= <<'EOQ';
let $total := count($stellen)

return
<report>
  <suche>
    <text>{$text}</text>
    <dozent>{$dozent}</dozent>
    <von>{$von}</von>
    <bis>{$bis}</bis>
    <fakultaet>{$fakultaet}</fakultaet>
  </suche>
  <stellen total="{$total}" start="{$start}" interval="{$interval}">
  {
    for $v in subsequence($stellen, $start, $interval)
    let $dozenten := if ($v/v:dozent)
                   then $v/v:dozent
                   else (if ($v/v:ders)
                         then $v/v:ders/preceding::v:dozent[1]
                         else $v/ancestor::v:veranstaltungsgruppe/v:dozent[last()])
    let $kopf := $v/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle id="{$v/@xml:id}" semester="{$sem}" jahr="{$jahr}">
      <thema>{string($v/@x-thema)}</thema>
      <dozenten>{$dozenten}</dozenten>
      <text>{normalize-space($v)}</text>
    </stelle>
  }
  </stellen>
</report>
EOQ
    $query;
}

sub _tokenize {
    grep { $_ ne '' } map { normalize_chars($_) } split(/\W+/, shift);
}

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

        # text
        my $text = normalize_chars( strip_text( $va, 1 ) );

        # thema
        my @themen;

        # find relevant thema elements
        my $thema_xpath = 'ancestor::v:veranstaltungsgruppe/v:thema | v:thema';
        foreach my $t ( $xc->findnodes( $thema_xpath, $va ) ) {
            # add thema elements from group context to the search text
            unless ($t->parentNode->isSameNode($va) ) {
                $text .= " | " . normalize_chars( strip_text($t, 1) );
            }
            push @themen, $t;
        }

        # include section titles when a thema element requires context
        # or there are no thema elements at all
        if ( $xc->findnodes( 'v:thema[@kontext]', $va ) || @themen == 0 ) {
            my ($sg) = $xc->findnodes( 'ancestor::v:sachgruppe[1]/v:titel', $va );
            if ($sg) {
                unshift @themen, $sg;
                $text .= " | " . normalize_chars( strip_text( $sg, 1 ) );
            }
        }

        my @thema = map strip_text( $_, 2, [qw/seite anmerkung/] ), @themen;
        my $thema = join ' … ', @thema;
        $va->setAttribute( 'x-thema', $thema );

        # dozent

        # first we look for elements inside <veranstaltung>
        my @dozenten = $xc->findnodes( 'v:dozent | v:ders', $va );

        # if there aren't any we search the containing group
        unless (@dozenten) {
            @dozenten = $xc->findnodes(
                'ancestor::v:veranstaltungsgruppe/v:dozent[last()]'
                  . '| ancestor::v:veranstaltungsgruppe[v:ders][1]/v:ders',
                $va
            );

            $text .= " | " . normalize_chars( strip_text($_) ) for @dozenten;
        }

        my @dstrings;
        my @drefs;
        foreach my $d (@dozenten) {
            # capture ref attributes
            if (my $ref = $xc->findvalue('@ref', $d)) {
                push @drefs, $ref;
            }

            # get preceding <dozent> for <ders> elements
            if ( $d->localname eq 'ders' && !$xc->exists( '@ref', $d ) ) {
                my ($pre) = $xc->findnodes( 'preceding::v:dozent[1]', $d );
                $d = $pre if $pre;
            }

            # capture literal content
            push @dstrings, strip_text( $d ) unless $d->localname eq 'ders';
        }

        $va->setAttribute( 'x-dozenten',
            normalize_chars( join '; ', @dstrings ) )
          if @dstrings;
        $va->setAttribute( 'x-dozentenrefs', join (' ', @drefs) ) if @drefs;

        $va->setAttribute( 'x-text', $text );
    }

    return $doc;
}

=head2 annotate_file

  $doc = annotate_file( $file );

Parses $file and passes the DOM to L<annotate_doc>.

=cut

sub annotate_file {
    my $doc = XML::LibXML->new->parse_file(shift);
    annotate_doc($doc);
}

=head2 normalize_chars

  $text = normalize_chars( $text );

Turns $text into lowercase and replaces accented characters with
non-accented ones. B<Note:> This method currently handles German
umlauts and sz only.

=cut

sub normalize_chars {
    my $txt = shift;
    $txt = lc $txt;
    $txt =~ s/\x{00e4}/ae/g; # ä
    $txt =~ s/\x{00f6}/oe/g; # ö
    $txt =~ s/\x{00FC}/ue/g; # ü
    $txt =~ s/\x{00DF}/ss/g; # ß
    $txt;
}

=head2 strip_text

  $txt = strip_text( $node );
  $txt = strip_text( $node, $expand );
  $txt = strip_text( $node, $expand, $elems );

Takes an XML::LibXML::Node, by default, removes all elements named
C<seite>, and returns the text content with normalized space.

When the second parameter $expand is set to C<1> the content of the
C<text> attribute of C<scil> elements is inserted after the respective
element. When $expand is set to a value greater than C<1> C<scil>
elements will be replaced by the content of their respective C<text>
attribute.

Optionally, the names of elements to be removed from $node can be
passed in an arrayref as the third parameter. If this is used C<seite>
must explicitly be included for the element to be removed.

=cut

sub strip_text {
    my $node = shift;
    my $expand = shift || 0;
    my $elems = shift;

    my $new = $node->cloneNode(1);

    # remove elements
    my @elems = $elems ? @$elems : qw/seite/;
    for my $name (@elems) {
        for my $e ( $new->getElementsByTagNameNS($Histvv::XMLNS, $name) ) {
            my $p = $e->parentNode;
            $p->removeChild($e);
        }
    }

    for my $a ( $new->getElementsByTagNameNS($Histvv::XMLNS, 'anmerkung') ) {
        my $text = XML::LibXML::Text->new(" [" . $a->textContent . "]");
        $a->replaceNode($text);
    }

    if ($expand) {
        for my $scil ( $new->getElementsByTagNameNS( $Histvv::XMLNS, 'scil' ) )
        {
            my $text = $scil->findvalue('@text');
            $text = " [$text]";
            my $textnode = XML::LibXML::Text->new($text);
            if ($expand > 1) {
                $scil->replaceNode($textnode);
            }
            else {
                my $p = $scil->parentNode;
                $p->insertAfter( $textnode, $scil );
            }
        }
    }

    $new->findvalue('normalize-space(.)');
}

=head1 SEE ALSO

L<Histvv>

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009-2012 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
