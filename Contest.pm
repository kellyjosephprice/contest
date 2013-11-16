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
    my ($self, $opts) = @_;
}

sub play_trick {
    my ($self, $msg) = @_;
    my $response = {};

    print Dumper($msg);

    if($msg->{state}->{can_challenge} && $self->challenge($msg)) {
        return {
            type => 'offer_challenge',
        }
    } 

    if($msg->{state}->{card}) {
        $response = {
            type => 'play_card',
            card => $self->get_next_highest($msg->{state}->{card}, $msg->{state}->{hand}),
        };
    } else {
        $response = {
            type => 'play_card',
            card => $self->get_mid_card($msg->{state}->{hand}),
        };
    }

    return $response;
}

sub accept_challenge {
    my ($self, $msg) = @_;

    if($self->challenge($msg)) {
        return {
            type => 'accept_challenge',
        };
    } else {
        return {
            type => 'reject_challenge',
        };
    }
}

sub get_next_highest {
    my( $self, $card, $hand ) = @_;
    my @higher_than = grep { $card < $_ } @$hand;

    if(@higher_than) {
        return (sort { $a <=> $b } @higher_than)[0];
    } else {
        return (sort { $a <=> $b } @$hand)[0];
    }
}

sub get_mid_card {
    my( $self, $hand ) = @_;
    
    return ($hand->[int(scalar(@$hand) / 2)]);
}

sub challenge {
    my ($self, $msg) = @_;
    my $sum = 0;
    my $mean = 1;

    $sum += $_ for @{ $msg->{state}->{hand};
    $mean = int($sum / scalar(@{ $msg->{state}->{hand} }));
    
    if($mean > 10) {
        # challenge accepted!!
        return 1;
    } else {
        return 0;
    }
}

1;
