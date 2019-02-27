package Games::TMX::Parser::Cell;

use Moo;
use Types::Standard qw( Int );

use constant {
    DIRS      => { map { $_ => 1 } qw( below left right above ) },
    ANTI_DIRS => {
        below => 'above',
        left  => 'right',
        right => 'left',
        above => 'below',
    },
};

use namespace::clean;

has [qw( x y )] => ( is => 'ro', isa => Int, required => 1 );

has tile => ( is => 'ro' );

has layer => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    handles  => [qw( get_cell width height )],
);

sub left  { shift->neighbor( -1,  0 ) }

sub right { shift->neighbor(  1,  0 ) }

sub above { shift->neighbor(  0, -1 ) }

sub below { shift->neighbor(  0,  1 ) }

sub xy { ( $_[0]->x, $_[0]->y ) }

sub neighbor {
    my ($self, $dx, $dy) = @_;

    my $x = $self->x + $dx;
    my $y = $self->y + $dy;

    return if $x < 0            || $y < 0;

    return if $x > $self->width || $y > $self->height;

    return $self->get_cell($x, $y);
}

sub seek_next_cell {
    my ($self, $dir) = @_;

    my %dirs = %{ DIRS() };
    delete $dirs{ ANTI_DIRS()->{$dir} } if $dir;

    for my $d (keys %dirs) {
        my $c = $self->$d;
        return [ $c, $d ] if $c && $c->tile;
    }

    return;
}

1;
