package Histvv::Apache;

use strict;
use warnings;

=head1 NAME

Histvv::Apache - the Histvv Apache handler

=head1 VERSION

Version 0.12

=cut

use version; our $VERSION = qv('0.12');

=head1 SYNOPSIS

  PerlModule Histvv::Apache
  <Location /vv>
    SetHandler perl-script
    PerlResponseHandler Histvv::Apache
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
use Histvv ();
use Histvv::Db ();
use Histvv::Search ();
use Histvv::Util ();

use Apache2::Const -compile => qw(:common :http);

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
let $veranstaltungen := collection()/v:vv[v:kopf/v:status/@komplett]
  //v:veranstaltung[tokenize(@x-dozentenrefs, "\s+") = $id]

return
if ($daten) then
<report>
  {$daten}
  <stellen>
  {
    for $v in $veranstaltungen return 
    <stelle semester="{$v/ancestor::v:vv/@x-semester}">
    {$v}
    {
     if ($v/v:dozent[@ref = $id])
     then ""
     else (if ($v/v:ders)
           then $v/v:ders/preceding::v:dozent[1]
           else $v/ancestor::v:veranstaltungsgruppe/v:dozent[@ref = $id][last()])
    }
    </stelle>
  }
  </stellen>
  <n>{count($veranstaltungen)}</n>
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

    suchformular => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $fakultaeten := distinct-values(collection()/v:vv//v:sachgruppe/@fakultät)

return
<formular>
  {
    for $vv in collection()/v:vv
    let $name := concat($vv/@x-semester, "")
    let $titel := concat($vv/v:kopf/v:beginn/v:jahr, " ", $vv/v:kopf/v:semester)
    return
    <semester>
      <name>{$name}</name>
      <titel>{$titel}</titel>
    </semester>
  }
  <fakultäten>
  {
    for $f in $fakultaeten
    return
    <fakultät>{$f}</fakultät>
  }
  </fakultäten>
</formular>
EOT

    pnd => <<'EOT',
declare namespace v = "http://histvv.uni-leipzig.de/ns/2007";

let $pnd := "%s"
let $dozent := collection()/v:dozentenliste/v:dozent[v:pnd=$pnd]

return
if ($dozent) then
<http>
  <location>/dozenten/{string($dozent/@xml:id)}.html</location>
</http>
else
()
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

# supported content types
my %Mime = (
    css => 'text/css',
    js  => 'application/x-javascript',
    gif => 'image/gif',
    jpg => 'image/jpeg',
    png => 'image/png'
);

# supported file extensions
my $Extensions = join '|', keys %Mime;

sub handler {
    my $r = shift;

    my $dbfile = $r->dir_config('HISTVV_DB');

    my $sharedir = Histvv::sharedir();

    my $xslfile = $r->dir_config('HISTVV_XSL');
    $xslfile = File::Spec->catfile( $sharedir, 'xsl', $xslfile )
      unless $xslfile =~ /^\//;

    my $custom_xslfile = $r->dir_config('HISTVV_CUSTOM_XSL') || undef;
    $custom_xslfile = File::Spec->catfile( $sharedir, 'xsl', $custom_xslfile )
      if $custom_xslfile && $custom_xslfile !~ /^\//;

    my %xsl_params = ( 'histvv-url' => "'" . $r->uri . "'" );

    (my $loc = $r->location) =~ s/\/$//;
    (my $url = $r->uri) =~ s/^$loc//;

    my ($xquery, $xml);

    if ($loc eq '/dozenten') {
        if ($url =~ /^\/(index\.html)?$/) {
            $xquery = $Queries{dozenten};
        } elsif ($url =~ /^\/galerie\.html$/) {
            $xquery = $Queries{dozenten};
        } elsif ($url =~ /^\/namen\.html$/) {
            $xquery = $Queries{dozentennamen};
        } elsif ($url =~ /^\/lookup$/) {
            my $rq = Apache2::Request->new($r);
            my $name = $rq->param('name') || return Apache2::Const::DECLINED;
            $name = Histvv::Util::xquery_escape( $name );
            my $query = $name =~ /\s/ ? 'normalize-space(v:nachname)' : 'v:nachname';
            $xquery = sprintf $Queries{dozentenlookup}, $name, $query;
        } elsif ($url =~ /^\/([-_a-z0-9]+)\.html$/) {
            my $id = $1;
            $xquery = sprintf $Queries{dozent}, $id;
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
                $wert = Histvv::Util::xquery_escape( $wert );
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
        return Apache2::Const::DECLINED
          unless $url eq '/' || $url eq '/index.html';
        if ( $r->args ) {
            my $rq = Apache2::Request->new($r);
            $xquery = Histvv::Search::build_xquery(
                text   => $rq->param('volltext') || '',
                dozent => $rq->param('dozent')   || '',
                fakultaet => join( " ", $rq->param('fakultaet') ),
                von      => $rq->param('von')   || '',
                bis      => $rq->param('bis')   || '',
                start    => $rq->param('start') || 1,
                interval => $rq->param('l')     || 50
            );
        }
        else {
            $xquery = $Queries{suchformular};
        }
    } elsif ($r->uri eq '/suche.html') {
        # redirect old style search page
        my $url = $r->construct_url('/suche/');
        $r->headers_out->set( Location => $url );
        return Apache2::Const::HTTP_MOVED_PERMANENTLY;
    } elsif ($loc eq '/pnd.txt') {
        $xquery = $Queries{dozenten};
        $xsl_params{'histvv-beacon-feed'} = "'" . $r->construct_url() . "'";
        $xsl_params{'histvv-beacon-target'} =
          "'" . $r->construct_url("/pnd/{ID}") . "'";
        $r->content_type("text/plain; charset=utf-8");
    } elsif ($r->uri =~ /^\/pnd\/([0-9]{8,9}[0-9X])$/) {
        $xquery = sprintf $Queries{pnd}, $1;
    } elsif ($r->uri =~ /^(\/\w+)*\/(\w+\.html)?$/) {
        my $uri = $2 ? $r->uri : ($1 || '') . "/index.html";
        my $docfile = File::Spec->catfile($r->document_root, $uri);
        my $distfile = File::Spec->catfile($sharedir, 'htdocs', $uri);
        my $file = -f $docfile ? $docfile : (-f $distfile ? $distfile : undef);
        if ($file && -r $file) {
            open F, $file;
            $xml .= $_ while (<F>);
            close F;
        } else {
            return Apache2::Const::DECLINED;
        }
    } elsif ($r->uri =~ /^(\/[-.\w]+)*\/([-.\w]+)\.($Extensions)$/) {
        my $ext = $3;

        # leave file in document root to apache
        my $docfile = File::Spec->catfile($r->document_root, $r->uri);
        return Apache2::Const::DECLINED if -f $docfile;

        my $file = File::Spec->catfile($sharedir, 'htdocs', $r->uri);
        if (-f $file && -r $file) {
            my $content;
            open F, $file;
            $content .= $_ while (<F>);
            close F;
            $r->content_type($Mime{$ext});
            _set_expires($r);
            print $content;
            return Apache2::Const::OK;
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

    if (my $url = $xmldom->findvalue('/http/location')) {
        $r->headers_out->set( Location => $r->construct_url($url) );
        return Apache2::Const::REDIRECT;
    }

    my $xsldom = $Xp->parse_file($xslfile);
    my $stylesheet = $Xt->parse_stylesheet($xsldom);

    my $html;
    eval { $html = $stylesheet->transform($xmldom, %xsl_params) };
    if ($@) {
        warn "$@\n";
        return Apache2::Const::SERVER_ERROR;
    }

    if ($custom_xslfile && -f $custom_xslfile) {
        my $xsldom = $Xp->parse_file($custom_xslfile);
        my $stylesheet = $Xt->parse_stylesheet($xsldom);
        eval { $html = $stylesheet->transform($html, %xsl_params) };
        if ($@) {
            warn "$@\n";
            return Apache2::Const::SERVER_ERROR;
        }
    }

    _set_expires($r);

    if ($r->args eq 'report=xml') {
        $r->content_type('text/plain; charset=utf-8');
        print "$xml";
    } else {
        $r->content_type('text/html; charset=utf-8')
          if $r->content_type eq ''
              || $r->content_type eq 'httpd/unix-directory';
        print $stylesheet->output_as_bytes($html);
    }

    if (   $ENV{HISTVV_DEBUG}
        && $r->content_type =~
        /^(text\/html|text\/xml|application\/xhtml\+xml)/ )
    {
        print "\n\n";
        print "<!--\n";
        print "URI: " . $r->uri . "\n";
        print "Location: " . $r->location . "\n";
        print "Document Root: " . $r->document_root . "\n";
        print "URL: " . $url . "\n";
        print "ARGS: " . $r->args . "\n";
        print "DB: $dbfile\n";
        print "XSL: $xslfile\n";
        print "Custom XSL: $custom_xslfile\n" if $custom_xslfile;
        print "$xquery\n" if $xquery;
        print "-->\n";
    }

    return Apache2::Const::OK;
}

sub _set_expires {
    my $r = shift;
    if ( $ENV{HISTVV_EXPIRES} && $ENV{HISTVV_EXPIRES} =~ /^[0-9]+$/ ) {
        $r->headers_out->add( 'Expires' =>
              Apache2::Util::ht_time( $r->pool, time + $ENV{HISTVV_EXPIRES} ) );
    }
}

=head1 AUTHOR

Carsten Milling, C<< <cmil at hashtable.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007, 2008 Carsten Milling, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
