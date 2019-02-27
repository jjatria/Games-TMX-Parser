package Games::TMX::Parser::Map;

use Moose;
use Games::TMX::Parser::Layer;
use Games::TMX::Parser::TileSet;

extends 'Games::TMX::Parser::MapElement';

has [qw(layers tilesets width height tile_width tile_height tiles_by_id)] =>
    (is => 'ro', lazy_build => 1);

sub _build_layers {
    my $self = shift;
    return {map { $_->att('name') =>
        Games::TMX::Parser::Layer->new(el => $_, map => $self)
    } $self->children('layer') };
}

sub _build_tiles_by_id {
    my $self  = shift;
    my @tiles = map { @{$_->tiles} } @{ $self->tilesets };
    return {map { $_->id => $_ } @tiles};
}

sub _build_tilesets {
    my $self = shift;
    return [map {
        Games::TMX::Parser::TileSet->new(el => $_)
    } $self->children('tileset') ];
}

sub _build_width       { shift->att('width') }
sub _build_height      { shift->att('height') }
sub _build_tile_width  { shift->att('tile_width') }
sub _build_tile_height { shift->att('tile_height') }

sub get_layer { shift->layers->{pop()} }
sub get_tile  { shift->tiles_by_id->{pop()} }

1;
