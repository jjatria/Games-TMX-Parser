package Games::TMX::Parser::Tile;

our $VERSION = '1.000000';

use Moo;
use Types::Standard qw( HashRef Int );

use namespace::clean;

has id      => (is => 'ro', isa => Int, required => 1);
has tileset => (is => 'ro', weak_ref => 1, required => 1);

has 'x' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $tileset = $_[0]->tileset;
        my $local_id = $_[0]->id - $tileset->first_gid;
        return $local_id % $tileset->columns;
    },
);

has 'y' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $tileset = $_[0]->tileset;
        my $local_id = $_[0]->id - $tileset->first_gid;
        return int( $local_id / $tileset->columns );
    },
);

has properties => (is => 'ro', isa => HashRef, default => sub { {} });

sub get_prop {
    my ($self, $name) = @_;
    return $self->properties->{$name};
}

1;
