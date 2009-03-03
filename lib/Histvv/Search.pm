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

Version 0.06

=cut

our $VERSION = '0.06';

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

my @faculties = qw/Theologie Jura Medizin Philosophie/;

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
        push @fac, $fac if grep { $fac eq $_ } @faculties;
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

    $vars = sprintf $vars, map ( {
            $_ ||= '';
              s/"/""/g;
              $_
        } $start,
        $interval,
        $text,
        #$args{text},
        $doz,
        #$args{dozent},
        $args{fakultaet},
        $von,
        $bis );

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
        my $text = normalize_chars( strip_text( $va ) );

        # thema
        my @themen =
          $xc->findnodes( 'ancestor::v:veranstaltungsgruppe/v:thema | v:thema',
            $va );
        if ( $xc->findnodes( 'v:thema[@kontext]', $va ) || @themen == 0 ) {
            my ($sg) = $xc->findnodes( 'parent::v:sachgruppe/v:titel', $va );
            if ($sg) {
                unshift @themen, $sg;
                $text .= " ";
                $text .= normalize_chars( strip_text( $sg ) );
            }
        }
        my @thema = map strip_text( $_ ), @themen;

        my $thema = join ' … ', @thema;
        $va->setAttribute( 'x-thema', $thema );

        # dozent

        # first we look for elements inside <veranstaltung>
        my @dozenten = $xc->findnodes( 'v:dozent | v:ders', $va );

        # if there aren't any we search the containing
        # <veranstaltunsgruppe>
        unless (@dozenten) {
            @dozenten = $xc->findnodes(
                'ancestor::v:veranstaltungsgruppe/v:dozent[last()]', $va );
        }

        my @dstrings;
        foreach my $d (@dozenten) {

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

Replaces accented characters in $text with non-accented ones. B<Note:>
This method currently handles German umlauts and sz only.

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

Takes an XML::LibXML::Node, removes all elements named C<seite>, and
returns the text content with normalized space.

=cut

sub strip_text {
    my $node = shift;

    my $new = $node->cloneNode(1);

    for my $s ( $new->getElementsByTagNameNS($Histvv::XMLNS, 'seite') ) {
        my $p = $s->parentNode;
        $p->removeChild( $s );
    }

    $new->findvalue('normalize-space(.)');
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
