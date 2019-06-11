package main;

use Test2::V0;

use FindBin qw($Bin);
use File::Spec;
use Games::TMX::Parser;

my $map = Games::TMX::Parser->new(
    map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
    map_file => 'tower_defense.tmx',
)->map;

is $map->properties, hash {
    field 'map-raw'   => 1;
    field 'map-false' => '';
    field 'map-true'  => 1;
    field 'map-var'   => 'false';
    end;
};

is $map->get_prop('map-var'), 'false';
is $map->get_prop('foo'), U;

is $map->get_layer('path')->properties, hash {
    field 'layer-raw'   => 1;
    field 'layer-false' => '';
    field 'layer-true'  => 1;
    field 'layer-var'   => 'false';
    end;
};

is $map->get_layer('path')->get_prop('layer-var'), 'false';
is $map->get_layer('path')->get_prop('foo'), U;

is $map->tilesets->[1]->properties, hash {
    field 'tileset-raw'   => 1;
    field 'tileset-false' => '';
    field 'tileset-true'  => 1;
    field 'tileset-var'   => 'false';
    end;
};

is $map->tilesets->[1]->get_prop('tileset-var'), 'false';
is $map->tilesets->[1]->get_prop('foo'), U;

done_testing;
