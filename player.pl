#!/usr/bin/perl -Ilib
#
# example Perl bot for 2013 Barracuda Networks, Inc. programming contest

use strict;
use warnings;

use lib 'lib';
use Data::Dumper;
use Getopt::Long qw(:config bundling);
use IO::Socket::INET;
use JSON;
use Pod::Usage;

use Contest;

use constant { LOG => "./contest.log" };

sub debug(@);
sub log($);

our %opts;
our $RECONNECT_DELAY = 15;    # seconds
our $GAME_ID         = -1;

GetOptions( \%opts, 'host|t=s', 'port|p=i', 'help|h', 'verbose|v', )
  or pod2usage(1);

pod2usage(1) if $opts{help};
pod2usage("--host and --port are required") if !( $opts{host} and $opts{port} );

run( $opts{host}, $opts{port} );
exit;

##

sub run {
    my ( $host, $port ) = @_;
    my $engine = Contest->new();
    $engine->init();

    while (1) {
        eval {
            my $s = IO::Socket::INET->new(
                PeerAddr => $host,
                PeerPort => $port,
            ) or die "Can't connect to [$host:$port]: $@";

            while (1) {
                my $msg = get_message($s);

                my $response = handle_message( $msg, $engine );
                if ($response) {
                    send_message( $s, $response );
                }
            }
        };
        if ($@) {
            warn "Error: $@";
        }
        warn "reconnecting in $RECONNECT_DELAY seconds";
        sleep $RECONNECT_DELAY;
    }
}

sub handle_message {
    my ( $msg, $engine ) = @_;

    # Move request
    if ( $msg->{type} eq 'request' ) {
        if ( $GAME_ID != $msg->{state}{game_id} ) {
            $GAME_ID = $msg->{state}{game_id};
            debug "new game $GAME_ID";
        }

        if ( $msg->{request} eq 'request_card' ) {
            return {
                request_id => $msg->{request_id},
                type       => "move",
                response   => $engine->play_trick($msg),
            };
        }
        elsif ( $msg->{request} eq 'challenge_offered' ) {
            return {
                request_id => $msg->{request_id},
                type       => "move",
                response   => $engine->accept_challenge($msg),
            };
        }
    }

    elsif ( $msg->{type} eq 'result' ) {
        $engine->parse_result($msg);
    }
    elsif ( $msg->{type} eq 'error' ) {
        debug "Error: $msg->{message}";

        # need to register IP address
        if ( $msg->{seen_host} ) {
            exit 1;
        }
    }
    return;
}

sub send_message {
    my ( $s, $msg ) = @_;

    my $json    = encode_json($msg);
    my $to_send = length($json);
    $s->send( pack( "N", $to_send ) );

    while ( $to_send > 0 ) {
        my $writelen = $s->send($json)
          or die "Error sending message: $!";

        $to_send -= $writelen;
        $json = substr( $json, 0, $writelen );
    }
}

sub get_message {
    my ($s) = @_;

    my $buf;
    my $rv = $s->recv( $buf, 4 );
    if ( not defined($rv) or length($buf) < 4 ) {
        die "Error receiving size: " . ( $! || "(eof)" );
    }

    my $len = unpack( "N", $buf );

    my $to_read = $len;
    my $json    = "";

    while ( $to_read > 0 ) {
        my $buf;
        defined( $s->recv( $buf, $to_read ) )
          or die
          "Error receiving message: $! Still [$to_read] bytes left to read";

        $to_read -= length($buf);
        $json .= $buf;
    }

    return decode_json($json);
}

sub debug(@) {
    if ( $opts{verbose} ) {
        print $_. "\n" for @_;
    }
}

sub log($) {
    my $msg = shift;

    open( my $log, ">>", LOG );
    print $log scalar( localtime(time) ) . " - " . $msg . "\n";
    close $log;
}

__END__

=head1 NAME

player.pl - example bot for programming contest

=head1 SYNOPSIS

player.pl [ options... ]

 Options:
   -t --host HOST            Connect to server HOST
   -p --port PORT            Connect to port PORT on server
   -v --verbose              Increase debugging output

   -h --help                 Display this help text

=head1 OPTIONS

=over

=item B<-t>, B<--host> HOST

Connect to contest server HOST.

=item B<-p>, B<--port> PORT

Connect to port PORT on the contest server.

=item B<-v>, B<--verbose>

Increase verbosity of program.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2013 Barracuda Networks, Inc. All Rights reserved.

=head1 SEE ALSO

=cut

