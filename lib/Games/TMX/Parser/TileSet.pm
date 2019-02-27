package Games::TMX::Parser::TileSet;

use Moose;
use Games::TMX::Parser::Tile;
use List::MoreUtils qw(natatime);

extends 'Games::TMX::Parser::MapElement';

has [qw(first_gid image tiles width height tile_width tile_height tile_count)] =>
    (is => 'ro', lazy_build => 1);

sub _build_tiles {
    my $self = shift;
    my $first_gid = $self->first_gid;

    # index tiles with properties
    my $prop_tiles = {map {
        my $el = $_;
        my $id = $first_gid + $el->att('id');
        my $properties = {map {
           $_->att('name'), $_->att('value')
        } $el->first_child('properties')->children};
        my $tile = Games::TMX::Parser::Tile->new
            (id => $id, properties => $properties, tileset => $self);
        ($id => $tile);
    } $self->children('tile')};

    # create a tile object for each tile in the tileset
    # unless it is a tile with properties
    my @tiles;
    my $it = natatime $self->width, 1..$self->tile_count;
    while (my @ids = $it->()) {
        for my $id (@ids) {
            my $gid = $first_gid + $id;
            my $tile = $prop_tiles->{$gid} ||
                Games::TMX::Parser::Tile->new(id => $gid, tileset => $self);
            push @tiles, $tile;
        }
    }
    return [@tiles];
}

sub _build_tile_count {
    my $self = shift;
    return ($self->width      * $self->height     ) /
           ($self->tile_width * $self->tile_height);
}

sub _build_first_gid   { shift->att('firstgid') }
sub _build_tile_width  { shift->att('tilewidth') }
sub _build_tile_height { shift->att('tileheight') }
sub _build_image       { shift->first_child('image')->att('source') }
sub _build_width       { shift->first_child('image')->att('width') }
sub _build_height      { shift->first_child('image')->att('height') }

1;
