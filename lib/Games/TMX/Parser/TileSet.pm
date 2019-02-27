package Games::TMX::Parser::TileSet;

use Moo;
use Games::TMX::Parser::Tile;
use List::MoreUtils qw(natatime);

extends 'Games::TMX::Parser::MapElement';

use namespace::clean;

has tiles => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $first_gid = $self->first_gid;

        # index tiles with properties
        my %prop_tiles = map {
            my $el = $_;
            my $id = $first_gid + $el->att('id');

            my %properties = map {
                $_->att('name') => $_->att('value')
            } $el->first_child('properties')->children;

            my $tile = Games::TMX::Parser::Tile->new(
                id         => $id,
                properties => \%properties,
                tileset    => $self
            );

            ( $id => $tile );
        } $self->children('tile');

        # create a tile object for each tile in the tileset
        # unless it is a tile with properties
        my @tiles;
        my $it = natatime $self->width, 0..$self->tile_count - 1;

        while ( my @ids = $it->() ) {
            for my $id (@ids) {
                my $gid = $first_gid + $id;
                my $tile = $prop_tiles{$gid}
                    || Games::TMX::Parser::Tile->new(
                        id      => $gid,
                        tileset => $self
                    );

                push @tiles, $tile;
            }
        }

        return \@tiles;
    },
);

has tile_count  => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return
            ( $_[0]->width      * $_[0]->height ) /
            ( $_[0]->tile_width * $_[0]->tile_height );
    },
);

for my $name (qw( first_gid tile_width tile_height )) {
    my $attribute = $name;
    $attribute =~ s/_//g;
    has $name => (
        is      => 'ro',
        lazy    => 1,
        default => sub { shift->att($attribute) },
    );
}

for my $name (qw( width height )) {
    has $name => (
        is      => 'ro',
        lazy    => 1,
        default => sub { shift->first_child('image')->att($name) },
    );
}

has image => (
    is      => 'ro',
    lazy    => 1,
    default => sub { shift->first_child('image')->att('source') },
);

1;
