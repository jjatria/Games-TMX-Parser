package main;

use Test2::V0;

use FindBin qw($Bin);
use File::Spec;
use Games::TMX::Parser;

my @files = qw(
    b64_raw.tmx
    b64_zlib.tmx
    b64_gzip.tmx
    csv.tmx
);

for (@files) {
    note 'Reading ' . $_;
    my $parser = Games::TMX::Parser->new(
        map_dir  => File::Spec->catfile($Bin, '..', 'eg'),
        map_file => $_,
    );

    my $map = $parser->map;

    is $map->layers, hash {
        field path      => E;
        field towers    => E;
        field waypoints => E;

        all_values object {
            prop blessed => 'Games::TMX::Parser::Layer';
        };

        end;
    }, 'layer';

    is $map, object {
        call [ get_layer => 'waypoints' ] => object {
            call_list [ find_cells_with_property => 'spawn_point' ] => array {
                item object {
                    prop blessed => 'Games::TMX::Parser::Cell';
                };
                end;
            };

            call_list [ find_cells_with_property => 'leave_point' ] => array {
                item object {
                    prop blessed => 'Games::TMX::Parser::Cell';
                };
                end;
            };
        };
    }, 'Get cells by property from layer';
}

done_testing;

