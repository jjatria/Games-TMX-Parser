package main;

use Test2::V0;

use FindBin qw($Bin);
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

    is $spawn, object {
        call x => 3;
        call y => 0;
        call_list xy => [ 3, 0 ];

        call tile => object {
            call id => 29;
            call [ get_prop => 'spawn_point' ] => T;
            call [ get_prop => 'leave_point' ] => F;
        };

        call left  => object { call x => 2; call y =>  0 };
        call right => object { call x => 4; call y =>  0 };
        call below => object { call x => 3; call y =>  1 };
        call above => U;
    };

    is $leave, object {
        call x => 21;
        call y => 16;
        call_list xy => [ 21, 16 ];

        call tile => object {
            call id => 27;
            call [ get_prop => 'spawn_point' ] => F;
            call [ get_prop => 'leave_point' ] => T;
        };

        call left  => object { call x => 20; call y => 16 };
        call right => object { call x => 22; call y => 16 };
        call below => U;
        call above => object { call x => 21; call y => 15 };
    };
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

    is \@cells, array {
        prop size => 39;

        all_items object { prop blessed => 'Games::TMX::Parser::Cell' };

        item 0  => object { call_list xy => [  3,  0 ] };

        item 12 => object { call_list xy => [  7,  8 ] };

        item 38 => object { call_list xy => [ 21, 16 ] };

        end;
    };
};

done_testing;
