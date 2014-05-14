package Data::EventStream::Clock;
use Moose::Role;
our $VERSION = "0.02";
$VERSION = eval $VERSION;

requires 'get_time';
requires 'set_time';
requires 'set_alarm';
requires 'check_alarm';
requires 'clear_alarm';

package Data::EventStream::RealtimeClock;
use Moose;
with 'Data::EventStream::Clock';
use Time::HiRes qw();

has _alarm_time => ( is => 'rw' );
has _alarm_cb   => ( is => 'rw' );

sub get_time {
    Time::HiRes::time();
}

sub set_time {
    shift->get_time;
}

sub set_alarm {
    my ( $self, $alarm_time, $alarm_cb ) = @_;
    $self->_alarm_time($alarm_time);
    $self->_alarm_cb($alarm_cb);
    $self->check_alarm;
}

sub check_alarm {
    my $self = shift;
    if ( $self->_alarm_time and $self->_alarm_time < $self->get_time ) {
        my $cb = $self->_alarm_cb;
        $self->clear_alarm;
        $cb->( $self->get_time );
    }
}

sub clear_alarm {
    my $self = shift;
    $self->_alarm_time(undef);
    $self->_alarm_cb(undef);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
