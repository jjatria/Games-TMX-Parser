package main;
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use File::Spec;
use Games::TMX::Parser;

my $parser = Games::TMX::Parser->new(
    map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
    map_file => 'tower_defense.tmx',
);

my $map = $parser->map;

subtest 'Directions' => sub {
    my $layer = $parser->map->get_layer('waypoints');

    my ($spawn) = $layer->find_cells_with_property('spawn_point');
    my ($leave) = $layer->find_cells_with_property('leave_point');

    is $spawn->x, 3, '->x';
    is $spawn->y, 0, '->y';
    is_deeply [ $spawn->xy ], [ 3, 0 ], '->xy';
    is $spawn->tile->id, 29, 'Cell has tile with right ID';

    is_deeply [ $spawn->left->xy ],  [ 2, 0 ], '$spawn->left';
    is_deeply [ $spawn->right->xy ], [ 4, 0 ], '$spawn->right';
    is_deeply [ $spawn->below->xy ], [ 3, 1 ], '$spawn->below';
    is          $spawn->above,         undef,  '$spawn->above';

    is_deeply [ $leave->left->xy ],  [ 20, 16 ], '$leave->left';
    is_deeply [ $leave->right->xy ], [ 22, 16 ], '$leave->right';
    is          $leave->below,         undef,    '$leave->below';
    is_deeply [ $leave->above->xy ], [ 21, 15 ], '$leave->above';
};

subtest 'Seek' => sub {
    my $layer = $parser->map->get_layer('path');

    my @cells;
    my ($cell)  = $layer->get_cell(  3,  0 );

    my $direction;
    for ( 0 .. 100 ) {
        push @cells, $cell;

        ( $cell, $direction ) = @{ $cell->seek_next_cell($direction) // [] }
            or last;
    }

    is scalar @cells, 39, 'Right number of cells in path';
    is_deeply [ $cells[0]->xy ], [ 3, 0 ],    'Correct start';
    is_deeply [ $cells[12]->xy ], [ 7, 8 ],   'Correct cell after crossroad';
    is_deeply [ $cells[38]->xy ], [ 21, 16 ], 'Correct end';
};

done_testing;
