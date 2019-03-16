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

my @test_towers = $map->get_layer('towers')
    ->find_cells_with_property('test_tower');

is scalar(@test_towers), 3, 'three test towers';

done_testing;
