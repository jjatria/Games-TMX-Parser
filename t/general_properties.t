package main;

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;
use File::Spec;
use Games::TMX::Parser;

my $map = Games::TMX::Parser->new(
    map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
    map_file => 'tower_defense.tmx',
)->map;

is_deeply $map->properties, {
    'map-raw'   => 1,
    'map-false' => '',
    'map-true'  => 1,
    'map-var'   => 'false',
};

is $map->get_prop('map-var'), 'false';
is $map->get_prop('foo'), undef;

is_deeply $map->get_layer('path')->properties, {
    'layer-raw'   => 1,
    'layer-false' => '',
    'layer-true'  => 1,
    'layer-var'   => 'false',
};

is $map->get_layer('path')->get_prop('layer-var'), 'false';
is $map->get_layer('path')->get_prop('foo'), undef;

is_deeply $map->tilesets->[1]->properties, {
    'tileset-raw'   => 1,
    'tileset-false' => '',
    'tileset-true'  => 1,
    'tileset-var'   => 'false',
};

is $map->tilesets->[1]->get_prop('tileset-var'), 'false';
is $map->tilesets->[1]->get_prop('foo'), undef;

done_testing;
