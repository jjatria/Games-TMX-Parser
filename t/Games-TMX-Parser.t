package main;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use File::Spec;
use Games::TMX::Parser;

for (qw( tower_defense.tmx split.tmx )) {
    note 'Reading ' . $_;
    my $parser = Games::TMX::Parser->new(
        map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
        map_file => $_,
    );

    my $map = $parser->map;

    is scalar(keys %{$map->layers}), 3, 'layer count';

    my $waypoints_layer = $map->get_layer('waypoints');

    my @spawn_cells = $waypoints_layer->find_cells_with_property('spawn_point');
    my @leave_cells = $waypoints_layer->find_cells_with_property('leave_point');

    is scalar(@spawn_cells), 1, 'one spawn cell';
    is scalar(@leave_cells), 1, 'one leave cell';
}

done_testing;

