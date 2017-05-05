#!/usr/bin/perl

my $test = 0;
if ($test) {
    print STDOUT "Content-Type: text/html; charset=utf-8\n\n";
    my $data = join( '', <DATA> );
    eval $data;
    if ($@) {
        print "<H1>Syntax  error!</H1>\n<PRE>\n";
        print $@;
        print "</PRE>\n";
        exit;
    }
}
###__END__

#---------------------------------------------------------------------------
#THE cclite SOFTWARE IS PROVIDED TO YOU "AS IS," AND WE MAKE NO EXPRESS
#OR IMPLIED WARRANTIES WHATSOEVER WITH RESPECT TO ITS FUNCTIONALITY,
#OPERABILITY, OR USE, INCLUDING, WITHOUT LIMITATION,
#ANY IMPLIED WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE, OR INFRINGEMENT.
#WE EXPRESSLY DISCLAIM ANY LIABILITY WHATSOEVER FOR ANY DIRECT,
#INDIRECT, CONSEQUENTIAL, INCIDENTAL OR SPECIAL DAMAGES,
#INCLUDING, WITHOUT LIMITATION, LOST REVENUES, LOST PROFITS,
#LOSSES RESULTING FROM BUSINESS INTERRUPTION OR LOSS OF DATA,
#REGARDLESS OF THE FORM OF ACTION OR LEGAL THEORY UNDER
#WHICH THE LIABILITY MAY BE ASSERTED,
#EVEN IF ADVISED OF THE POSSIBILITY OR LIKELIHOOD OF SUCH DAMAGES.
#---------------------------------------------------------------------------

=head1 NAME
 
ccsmsgate.cgi


=head1 SYNOPSIS

Controller for smsgateway transactions

=head1 DESCRIPTION


=head1 AUTHOR

Hugh Barnard

=head1 COPYRIGHT

(c) Hugh Barnard 2005-2014 GPL Licenced 

=cut

use lib '../../lib';
use strict;
use locale;
use HTML::SimpleTemplate;    # templating for HTML

use Ccu;                     # utilities + config + multilingual messages
use Cccookie;                # use the cookie module
use Ccvalidate;              # use the validation and javascript routines
use Cclite;                  # use the main motor
use Ccsecure;                # security and hashing
use Cclitedb;                # this probably should be delegated
use Ccconfiguration;         # new way of doing configuration
use Data::Dumper;

print "Content-Type: text/html; charset=utf-8\n\n";

# please de-comment to suit interface, only Cardboardfish has been heavily
# tested recently as of August 2010
# Textmarketer tested heavily with added functions May 2012
#
# Gammu extended and tested February 2014, in general, this will be preferred
# now because it removes dependency on http style commercial sms services
# towards a more autonomous 'bank in a box' model

use Ccsms::Textmarketer;
my $type = 'txt';

#use Ccsms::Cardboardfish;
#my $type = 'car';

#use Ccsms::Aql;
#my $type = 'aql' ;

#use Ccsms::Gammu;
#my $type = 'gam' ;
# end of interface choices

#--------------------------------------------------------------

$ENV{IFS} = " ";    # modest security

our %configuration     = readconfiguration();
our $configurationref  = \%configuration;
our %sms_configuration = readconfiguration('../../config/readsms.cf');

my $debug = $sms_configuration{'debug'};    # set debug level

my ( $fieldsref, $refresh, $metarefresh, $error, $html, $token, $db, $cookies,
    $templatename, $registry_private_value, $return_value );    # for the moment

my $cookieref = get_cookie();
my %fields    = cgiparse();
my @message_hash_refs;

#  this should use the version modules, but that makes life more
# complex for intermediate users

$fields{version} = "0.9.1";

# parse incoming fields the cardboardfish way...may give multiple messages
my ( $status, $originator, $destination, $dcs, $datetime, $udh, $message );
if ( $type eq 'car' ) {
    (@message_hash_refs) = convert_cardboardfish( $fields{'INCOMING'} );
}

#  this is part of conversion to transaction engine use. web mode, which
#  is the default will deliver html etc. engine mode will deliver data
#  as hash references, for example. There are quite a few things called 'mode'
#  in Cclite.pm, needs sorting out.

$fields{mode} = 'html';

#  this is the remote address from the client. It acts as a simple check in a direct
#  pay transaction from the REST interface. This is obviously not sufficient and
#  will get upgraded in the future

$fields{client_ip} = $ENV{REMOTE_ADDR};

#---------------------------------------------------------------------------
#
( $fields{home}, $fields{domain} ) =
  get_server_details();    # this is in Ccsecure, may need extra measures

$fields{initialPaymentStatus}   = $configuration{initialpaymentstatus};
$fields{systemMailAddress}      = $configuration{systemmailaddress};
$fields{systemMailReplyAddress} = $configuration{systemmailreplyaddress};

#--------------------------------------------------------------------
# This is the token that is to be carried everywhere, preventing
# session hijack etc. It's probably going to be a GnuPg public key
# anyway it's a public key of some kind related to the cclite installations
# private key, not transmitted and protected by passphrase
#
$token = $registry_private_value =
  $configuration{registrypublickey};    # for the moment, calculated later

if ( $type eq 'car' ) {

    # possible multiple messages loop to process

    foreach my $message_hash_ref (@message_hash_refs) {

        $fields{'status'}     = $message_hash_ref->{'status'};
        $fields{'originator'} = $message_hash_ref->{'originator'};
        $fields{'datetime'}   = $message_hash_ref->{'datetime'};
        $fields{'message'}    = $message_hash_ref->{'message'};

        my $fieldsref = \%fields;

        $return_value =
          gateway_sms_transaction( 'local', $configurationref, $fieldsref,
            $token );

    }

} else {

    # Aql, Textmarketer and gammu single messages...
    my $fieldsref = \%fields;

    $return_value =
      gateway_sms_transaction( 'local', $configurationref, $fieldsref, $token );

    debug( "rv after gateway is $return_value", undef );

}

# mobile number + raw string
# this is mainly to make Selenium etc. work...
print "running $return_value<br/>";

exit 0;

