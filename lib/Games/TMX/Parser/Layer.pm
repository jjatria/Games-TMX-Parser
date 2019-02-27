package Games::TMX::Parser::Layer;

use Moo;
use Games::TMX::Parser::Cell;
use List::MoreUtils qw(natatime);

extends 'Games::TMX::Parser::MapElement';

use namespace::clean;

has map => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    handles  => [qw(
        width height tile_width tile_height get_tile
    )],
);

has rows => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my @rows;
        my $it = natatime $self->width, $self->first_child->children('tile');
        my $y = 0;

        while ( my @row = $it->() ) {
            my $x = 0;

            push @rows, [
                map {
                    my $el = $_;
                    my $id = $el->att('gid');
                    my $tile;
                    $tile = $self->get_tile($id) if $id;
                    Games::TMX::Parser::Cell->new
                        (x => $x++, y => $y, tile => $tile, layer => $self)
                } @row
            ];

            $y++;
        }

        return \@rows;
    },
);

sub find_cells_with_property {
    my ($self, $prop) = @_;

    return grep {
        my $tile = $_->tile;
        $tile && exists $tile->properties->{$prop};
    } $self->all_cells;
}

sub get_cell { shift->rows->[shift]->[shift] }

sub all_cells { return map { @$_ } @{ shift->rows } }

1;
