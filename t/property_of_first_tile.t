package main;

use Test2::V0;

use FindBin qw($Bin);
use File::Spec;
use Games::TMX::Parser;

my $map = Games::TMX::Parser->new(
    map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
    map_file => 'tower_defense.tmx',
)->map;

my @test_towers = $map->get_layer('towers')
    ->find_cells_with_property('test_tower');

is \@test_towers, array { prop size => 3; etc }, 'three test towers';

done_testing;
