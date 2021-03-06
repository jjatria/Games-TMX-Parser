package Games::TMX::Parser::Cell;

our $VERSION = '1.000000';

use Moo;
use Types::Standard qw( Int );

use namespace::clean;

my @DIRS = qw( below left right above );

my %ANTI_DIRS = (
    below => 'above',
    left  => 'right',
    right => 'left',
    above => 'below'
);

has x => ( is => 'ro', isa => Int, required => 1 );
has y => ( is => 'ro', isa => Int, required => 1 );

has tile => ( is => 'ro' );

has layer => (
    is => 'ro',
    required => 1,
    weak_ref => 1,
    handles => [qw(
        get_cell
        height
        width
    )],
);

sub left  { shift->neighbor( -1, 0 ) }
sub right { shift->neighbor(  1, 0 ) }
sub above { shift->neighbor(  0,-1 ) }
sub below { shift->neighbor(  0, 1 ) }

sub xy { ( $_[0]->x, $_[0]->y ) }

sub neighbor {
    my ( $self, $dx, $dy ) = @_;

    my $x = $self->x + $dx;
    my $y = $self->y + $dy;

    return if $x < 0            || $y < 0;
    return if $x > $self->width || $y > $self->height;

    return $self->get_cell( $x, $y );
}

sub seek_next_cell {
    my ( $self, $dir ) = @_;

    my $opposite = $dir ? $ANTI_DIRS{$dir} : '';

    for my $direction (@DIRS) {
        next if $direction eq $opposite;

        my $cell = $self->$direction;
        return [ $cell, $direction ] if $cell && $cell->tile;
    }

    return;
}

1;
