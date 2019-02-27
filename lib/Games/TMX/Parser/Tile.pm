package Games::TMX::Parser::Tile;

use Moo;
use Types::Standard qw( Int HashRef );

use namespace::clean;

has id      => ( is => 'ro', required => 1, isa => Int );
has tileset => ( is => 'ro', required => 1, weak_ref => 1 );

has properties => (
    is => 'ro',
    isa => HashRef,
    default => sub { {} },
);

sub get_prop { shift->properties->{ +shift } }

1;
