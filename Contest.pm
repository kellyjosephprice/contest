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
    my $card = "";

    print Dumper($msg);

    if($msg->{state}->{card}) {

    } else {

    }
}

sub accept_challenge {
    my ($self, $msg) = @_;
}

1;
