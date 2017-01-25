
=head1 NAME

Ccopenid.pm

=head1 SYNOPSIS

Openid alpha implementation

=head1 DESCRIPTION

=head1 AUTHOR

Hugh Barnard

=head1 SEE ALSO


=head1 COPYRIGHT

(c) Hugh Barnard 2005 - 2010 GPL Licenced
 
=cut

package Ccopenid;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw();

use Net::OpenID::Consumer;
use strict;

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Net::OpenID::Consumer;

my $base_url = 'http://cclite.private.trunk';

my $cgi = CGI->new();
my $csr = Net::OpenID::Consumer->new(
    args            => $cgi,
    consumer_secret => "not very secret",
    required_root   => $base_url,
    debug           => 1,

    #    cache => $cache,
);

my $method = $ENV{REQUEST_METHOD};

if ( $method ne 'POST' ) {

    $csr->handle_server_response(
        not_openid => sub {
            header();
            print '<form method="POST" action="/">';
            print

              '<input type="text" value="" name="identifier">';
            print '<input type="submit" value="Go">';

            print '</form>';
        },
        setup_required => sub {
            my $setup_url = shift;
            redirect($setup_url);
        },
        cancelled => sub {
            header();
            print "Cancelled.";
        },
        verified => sub {
            my $vident = shift;
            header( 200, 'text/plain' );
            print "Authenticated as " . $vident->url . "\n\n";
            print Data::Dumper::Dumper($vident);
        },
        error => sub {
            my $err = shift;
            die($err);
        },
    );

} else {

    my $identifier = $cgi->param('identifier');

    my $claimed_identity = $csr->claimed_identity($identifier);

    my $check_url = $claimed_identity->check_url(
        return_to      => $base_url,
        trust_root     => $base_url,
        delayed_return => 0,
    );

    redirect($check_url);
}

sub plog;

{
    my $done_header = 0;

    sub header {
        my $status = shift || 200;
        my $type   = shift || "text/html; charset=utf-8";
        if ( !$done_header ) {
            plog "Sending header with status $status and type $type";
            print "Status: $status Blahblah\n";
            print "Content-type: $type\n\n";
            $done_header = 1;
        }
    }

    sub redirect {
        my $url = shift;
        if ( !$done_header ) {
            plog "Redirecting to $url\n";
            print "Status: 302 Found\n";
            print "Content-Type: text/html; charset=utf-8\n";
            print "Location: $url\n\n";
            print '<a href="' . $url . '">' . $url . '</a>';
        } else {
            die "Can't redirect. Header already sent!";
        }
    }
}

sub plog {
    print STDERR "Consumer-Test: ", @_, "\n";
}

1;
