package Histvv::Apache::GNDLink;

use strict;
use warnings;

=head1 NAME

Histvv::Apache::GNDLink - provide a list of links for GND numbers

=head1 VERSION

Version 0.11

=cut

use version; our $VERSION = qv('0.11');

=head1 SYNOPSIS

  <Location /gndlink>
    SetHandler perl-script
    PerlResponseHandler Histvv::Apache::GNDLink
    SetEnv HISTVV_BEACON_DB "/var/www/histvv/db/beacon.db"
  </Location>

=head1 DESCRIPTION

FIXME

=cut

use Apache2::RequestRec ();
use Apache2::URI ();
use Apache2::Const -compile => qw(:common :http);

use DBI;
use JSON;
use Encode;


my $HTML = <<EOF;
<!doctype html>
<html>
  <head>
    <title>Links for %s</title>
  <head>
  <body>
    <ul>
      %s
    </ul>
  <body>
</html>
EOF

sub handler {
    my $r = shift;

    my ($gnd, $type);
    if ($r->uri =~ /\/([0-9]{8,9}[0-9X])(?:\.(html|json))?$/) {
        $gnd = $1;
        $type = $2 || 'html'
    }
    else {
        return Apache2::Const::NOT_FOUND;
    }

    my $dbh = DBI->connect( "dbi:SQLite:dbname=$ENV{HISTVV_BEACON_DB}",
        "", "", { AutoCommit => 1, PrintError => 1 } )
      or die "$DBI::errstr";

    my $beacons =
      $dbh->selectall_arrayref('SELECT bname, bmeta, bvalue FROM beacons');

    my %beacons;
    $beacons{ $_->[0] }{ $_->[1] } = $_->[2] for @$beacons;

    my $links = $dbh->selectall_arrayref(
        'SELECT bname, source, target FROM links WHERE source = ?',
        { Slice => {} }, $gnd);

    my @links;
    for (@$links) {
        my $l;
        if ($_->{target}) {
            $l->{url} = $_->{target};
        } else {
            $l->{url} = $beacons{$_->{bname}}{TARGET};
            $l->{url} =~ s/\{ID\}/$gnd/;
        }
        $l->{label} = $beacons{$_->{bname}}{LABEL};
        push(@links, $l);
    }

    if ($type eq 'json') {
        $r->headers_out->set( 'Access-Control-Allow-Origin' => '*' );
        $r->headers_out->set( 'Access-Control-Allow-Methods' => 'GET' );
        $r->content_type("application/json; charset=utf-8");
        print Encode::decode("UTF-8", encode_json(\@links));
        print "\n";
    } else {
        $r->content_type("text/html; charset=utf-8");
        print _html($gnd, @links);
    }

    return Apache2::Const::OK;
}

sub _html {
    my $gnd = shift;
    my @links;
    for (@_) {
        push @links,
          sprintf( "<li><a href=\"%s\">%s</a></li>",
            $_->{url}, $_->{label} );
    }
    return sprintf( $HTML, $gnd, join("\n      ", @links));
}

1;
