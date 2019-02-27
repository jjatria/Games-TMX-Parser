package Games::TMX::Parser::Map;

use Moo;
use Games::TMX::Parser::Layer;
use Games::TMX::Parser::TileSet;

extends 'Games::TMX::Parser::MapElement';

use namespace::clean;

has layers => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            map {
                $_->att('name') => Games::TMX::Parser::Layer->new(
                    el => $_,
                    map => $_[0],
                )
            } $_[0]->children('layer')
        };
    },
);

has tilesets => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return [
            map {
                Games::TMX::Parser::TileSet->new( el => $_ )
            } $_[0]->children('tileset')
        ];
    },
);

has tiles_by_id => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my @tiles = map { @{ $_->tiles } } @{ $_[0]->tilesets };
        return { map { $_->id => $_ } @tiles };
    },
);

for my $name (qw( width height tile_width tile_height )) {
    my $attribute = $name;
    $attribute =~ s/_//g;
    has $name => (
        is      => 'ro',
        lazy    => 1,
        default => sub { shift->att($attribute) },
    );
}

sub get_layer { shift->layers->{ +pop } }

sub get_tile  { shift->tiles_by_id->{ +pop } }

1;
