package Contest;

use strict;
use warnings;

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
}

1;
