package Contest;

use strict;
use warnings;

use Data::Dumper;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub init {
    my ( $self, $opts ) = @_;
    $self->{avg_threshold} = 10;
    $self->{all_threshold} = 10;
}

sub play_trick {
    my ( $self, $msg ) = @_;
    my $response = {};

    if ( $msg->{state}->{can_challenge} && $self->challenge($msg) ) {
        return { type => 'offer_challenge', };
    }

    if ( $msg->{state}->{card} ) {
        $response = {
            type => 'play_card',
            card => $self->get_next_highest(
                $msg->{state}->{card},
                $msg->{state}->{hand}
            ),
        };
    }
    else {
        $response = {
            type => 'play_card',
            card => $self->get_mid_card( $msg->{state}->{hand} ),
        };
    }

    return $response;
}

sub accept_challenge {
    my ( $self, $msg ) = @_;

    if ( $self->challenge($msg) ) {
        print "Challenge Accepted!\n";
        return { type => 'accept_challenge', };
    }
    else {
        print "Denied!\n";
        return { type => 'reject_challenge', };
    }
}

sub get_next_highest {
    my ( $self, $card, $hand ) = @_;
    my @higher_than = grep { $card < $_ } @$hand;

    if (@higher_than) {
        return ( sort { $a <=> $b } @higher_than )[0];
    }
    else {
        return ( sort { $a <=> $b } @$hand )[0];
    }
}

sub get_mid_card {
    my ( $self, $hand ) = @_;

    return ( $hand->[ int( ( scalar(@$hand) - 1 ) / 2 ) ] );
}

sub challenge {
    my ( $self, $msg ) = @_;

    if ( $self->mean($msg) > $self->{avg_threshold} ) {
        print "Challenge! (average)\n";
        return 1;
    }
    elsif ( $self->high_cards($msg) >= $self->need_to_win($msg) ) {
        print "Challenge! (high cards)\n";
        return 1;
    }
    else {
        return 0;
    }
}

sub high_cards {
    my ( $self, $msg ) = @_;
    return grep { $_ > $self->{all_threshold} } @{ $msg->{state}->{hand} };
}

sub need_to_win {
    my ( $self, $msg ) = @_;
    my $need_to_win = $self->points_to_win($msg) - $msg->{state}->{your_tricks};
    return $need_to_win;
}

sub points_to_win {
    my ($self, $msg) = @_;
    my $points = 3;
    my $tied = $msg->{state}->{total_tricks} - $msg->{state}->{your_tricks} - $msg->{state}->{their_tricks};

    $points -= int($tied / 2);

    return $points;
}

sub mean {
    my ( $self, $msg ) = @_;
    my $sum  = 0;
    my $mean = 1;

    $sum += $_ for @{ $msg->{state}->{hand} };
    $mean = int( $sum / scalar( @{ $msg->{state}->{hand} } ) );

    return $mean;
}

sub parse_result {
    my($self, $msg) = @_;

    if($msg->{result}->{type} eq 'trick_won') {
        
    } elsif($msg->{result}->{type} eq 'hand_done') {

    } elsif($msg->{result}->{type} eq 'game_won') {
        if($msg->{result}->{by} == $msg->{your_player_num} ) {
            print "We are the champions!\n";
        }
    } elsif($msg->{result}->{type} eq 'trick_tied') {

    }
}

1;
