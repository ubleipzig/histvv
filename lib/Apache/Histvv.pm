package Apache::Histvv;

use strict;
use warnings;

=head1 NAME

Apache::Histvv - the Histvv Apache handler

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

  PerlModule Apache::Histvv
  <Location /vv>
    SetHandler perl-script
    PerlResponseHandler Apache::Histvv
  </Location>

=head1 DESCRIPTION

FIXME

=cut

use Apache2::RequestRec ();
use Apache2::RequestIO  ();
use Apache2::Request ();
use Apache2::Util ();
use Apache2::URI ();
use XML::LibXML ();
use XML::LibXSLT ();
use File::Spec ();
use Histvv::Db ();
use Histvv::Search ();

use Apache2::Const -compile => qw(:common);

my $Xp = XML::LibXML->new();
$Xp->no_network(1);
$Xp->load_ext_dtd(0);
$Xp->clean_namespaces(1);
my $Xt = XML::LibXSLT->new();

my %Queries = (
    index => q{
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";
<index>
{
for $d in collection()/v:vv
let $k := $d/v:kopf
let $sem := if ($k/v:semester = "Winter") then "w" else "s"
return
<vv name="{concat($k/v:beginn/v:jahr, $sem)}" >
  <titel>{concat($k/v:semester, "semester ", $k/v:beginn/v:jahr)}</titel>
  <vnum>{count($d//v:veranstaltung)}</vnum>
  {if ($k/v:status/@komplett = "ja") then <komplett/> else ''}
</vv>
}
</index>
},

    semester => q{
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";
for $d in collection()/v:vv
let $k := $d/v:kopf
where $k/v:status[@komplett = "ja"]
  and $k/v:semester = "%s"
  and $k/v:beginn/v:jahr = "%d"
return $d
},

    dozenten => q{
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";
for $d in collection()/v:dozentenliste[1]
return $d
},

   dozentennamen => q{
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $namen := collection()/v:vv[v:kopf/v:status/@komplett]
                         //v:dozent[not(@ref)]
                          /v:nachname[not(v:seite)]/normalize-space()

let $neu := for $n in distinct-values($namen)
            return
            <dozent xmlns="http://histvv.uni-leipzig.de/ns/2007">
              <name><nachname>{$n}</nachname></name>
            </dozent>

let $alt := collection()/v:dozentenliste/v:dozent[@xml:id]

return
<dozentenliste xmlns="http://histvv.uni-leipzig.de/ns/2007" xml:lang="de">
  <universität>Leipzig</universität>
  {
    for $d in ( $alt | $neu )
    let $name := $d/v:name
    order by $name/v:nachname, not($name/v:vorname), $name/v:vorname
    return $d
  }
</dozentenliste>
},

    dozent => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $id := "%s"

let $daten := collection()/v:dozentenliste/v:dozent[@xml:id=$id]
let $stellen := collection()/v:vv[v:kopf/v:status/@komplett]
  //(v:dozent[@ref=$id] | v:ders[@ref=$id])

return
if ($daten) then
<report>
  {$daten}
  <stellen >
  {
    for $d in $stellen
    let $node := $d/..
    let $s := $node/preceding::v:seite[1]
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '1'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {normalize-space($node)}
    </stelle>
  }
  </stellen>
</report>
else
()
EOT

    dozentenlookup => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $name := "%s"

let $stellen := collection()/v:vv[v:kopf/v:status/@komplett]
  //v:dozent[not(@ref) and %s=$name]

return
<report>
  <name>{$name}</name>
  <stellen >
  {
    for $d in $stellen
    let $node := $d/..
    let $s := $node/preceding::v:seite[1]
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '1'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {normalize-space($node)}
    </stelle>
  }
  </stellen>
</report>
EOT

    elements => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $werte := distinct-values(
  collection()/v:vv[v:kopf/v:status/@komplett]//v:%s
  /normalize-space())

return
<report>
  <element>%s</element>
  <werte>
  {
    for $w in $werte
    order by $w
    return
    <w>{$w}</w>
  }
  </werte>
</report>
EOT

    elementlookup => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $value := "%s"

let $stellen := collection()/v:vv[v:kopf/v:status/@komplett]
  //v:%s[normalize-space(.)=$value]

let $n := count($stellen)

return
<report>
  <element>%s</element>
  <value>{$value}</value>
  <stellen>
  {
    for $d in $stellen
    let $node := $d/..
    let $s := if ($n < 100)
      then $node/preceding::v:seite[1]
      else ()
    let $snr := if ($s)
                then (if ($s/@nr) then $s/@nr else $s/string())
                else '0'
    let $kopf := $d/ancestor::v:vv/v:kopf
    let $sem := $kopf/v:semester/string()
    let $jahr := $kopf/v:beginn/v:jahr/string()
    return
    <stelle semester="{$sem}" jahr="{$jahr}" seite="{$snr}">
    {$node}
    </stelle>
  }
  </stellen>
</report>
EOT

);

my @Elems = qw/funktion gebühr grad modus ort zeit/;


sub handler {
    my $r = shift;

    my $dbfile = $r->dir_config('HISTVV_DB');
    my $xslfile = $r->dir_config('HISTVV_XSL');

    (my $loc = $r->location) =~ s/\/$//;
    (my $url = $r->uri) =~ s/^$loc//;

    my ($xquery, $xml);

    if ($loc eq '/dozenten') {
        if ($url =~ /^\/(index\.html)?$/) {
            $xquery = $Queries{dozenten};
        } elsif ($url =~ /^\/namen\.html$/) {
            $xquery = $Queries{dozentennamen};
        } elsif ($url =~ /^\/lookup$/) {
            my $rq = Apache2::Request->new($r);
            my $name = $rq->param('name') || return Apache2::Const::DECLINED;
            $name =~ s/"/""/g;
            my $query = $name =~ /\s/ ? 'normalize-space(v:nachname)' : 'v:nachname';
            $xquery = sprintf $Queries{dozentenlookup}, $name, $query;
        } elsif ($url =~ /^\/([-_a-z0-9]+)\.html$/) {
            $xquery = sprintf $Queries{dozent}, $1;
        } else {
            return Apache2::Const::DECLINED;
        }
    } elsif ($loc eq '/vv') {
        if ( $url =~ /^\/([0-9]{4})(w|s)\.html$/ ) { # single VV
            my $year = $1;
            my $semester = $2 eq 'w' ? 'Winter' : 'Sommer';
            $xquery = sprintf $Queries{semester}, $semester, $year;
        }
        elsif ( $url =~ /^\/(index\.html)?$/ ) { # list of VVs
            $xquery = $Queries{index};
        }
        else {
            return Apache2::Const::DECLINED;
        }
    } elsif ($loc eq '/elements') {
        my $elems = join '|', @Elems;
        my $rx = qr/^\/($elems)$/;
        if ($url =~ $rx) {
            my $elem = $1;
            my $rq = Apache2::Request->new($r);
            my $wert = $rq->param('w');
            if ( $wert ) {
                $wert =~ s/"/""/g;
                $xquery = sprintf $Queries{elementlookup}, $wert, $elem, $elem;
            }
            else {
                $xquery = sprintf $Queries{elements}, $elem, $elem;
            }
        }
        else {
            return Apache2::Const::DECLINED;
        }
    } elsif ($loc eq '/suche') {
        return Apache2::Const::DECLINED unless $url eq '/';
        unless ($r->args) {
            my $url = $r->construct_url('/suche.html');
            $r->headers_out->set( Location => $url );
            return Apache2::Const::REDIRECT;
        }
        my $rq = Apache2::Request->new($r);
        $xquery = Histvv::Search::build_xquery(
            text      => $rq->param('volltext')  || '',
            dozent    => $rq->param('dozent')    || '',
            fakultaet => $rq->param('fakultaet') || '',
            von       => $rq->param('von')       || '',
            bis       => $rq->param('bis')       || '',
            start     => $rq->param('start')     || 1,
            interval  => $rq->param('l')         || 10,

        );
    } elsif ($r->uri =~ /^\/(\w+\.html)?$/) {
        my $uri = $1 ? $r->uri : '/index.html';
        my $file = File::Spec->catfile($r->document_root, $uri);
        if (-f $file && -r $file) {
            open F, $file;
            $xml .= $_ while (<F>);
            close F;
        } else {
            return Apache2::Const::DECLINED;
        }
    } else {
        return Apache2::Const::DECLINED;
    }

    if ($xquery && ! $xml) {
        my $db = Histvv::Db->new( $dbfile, { private => 1 } );
        my @results = $db->query_all( $xquery );
        return Apache2::Const::NOT_FOUND unless @results > 0;
        $xml = $results[0];
    }

    my $xmldom = $Xp->parse_string($xml);
    my $xsldom = $Xp->parse_file($xslfile);
    my $stylesheet = $Xt->parse_stylesheet($xsldom);

    my %params = ( 'histvv-url' => "'" . $r->uri . "'" );

    my $html;
    eval { $html = $stylesheet->transform($xmldom, %params) };
    if ($@) {
        warn "$@\n";
        return Apache2::Const::SERVER_ERROR;
    }

    # set Expires header to support caching of URLs with query strings
    if ( $ENV{HISTVV_EXPIRES} =~ /^[0-9]+$/ ) {
        $r->headers_out->add( 'Expires' =>
              Apache2::Util::ht_time( $r->pool, time + $ENV{HISTVV_EXPIRES} ) );
    }

    if (0) {
        $r->content_type('text/plain');
        print "$xml";
    } else {
        #$r->content_type('application/xhtml+xml');
        $r->content_type('text/html');
        print $stylesheet->output_as_bytes($html);
    }

    if ( $ENV{HISTVV_DEBUG} ) {
        print "\n\n";
        print "<!--\n";
        print "URI: " . $r->uri . "\n";
        print "Location: " . $r->location . "\n";
        print "Document Root: " . $r->document_root . "\n";
        print "URL: " . $url . "\n";
        print "ARGS: " . $r->args . "\n";
        print "DB: $dbfile\n";
        print "XSL: $xslfile\n";
        print "$xquery\n" if $xquery;
        print "-->\n";
    }

    return Apache2::Const::OK;
}

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007, 2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
