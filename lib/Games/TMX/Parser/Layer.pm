package Games::TMX::Parser::Layer;

use Moo;
use List::MoreUtils qw(natatime);
use MIME::Base64 qw(decode_base64);
use Compress::Zlib;
use Games::TMX::Parser::Cell;

has map => (is => 'ro', required => 1, weak_ref => 1, handles => [qw(
    width height tile_width tile_height get_tile
)]);

has index => ( is => 'ro', default => 0 );

extends 'Games::TMX::Parser::MapElement';

has rows => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $data = $self->first_child('data');
        my $encoding    = $data->att('encoding') // '';
        my $compression = $data->att('compression') // '';

        my @element_ids;

        if ( $encoding eq 'csv' ) {
            my $text = $data->text;
            $text =~ s/\s//g;
            @element_ids = split /,/, $text;
        }
        elsif ( $encoding eq 'base64' ) {
            my $decoded = decode_base64 $data->text;

            if ( $compression eq 'zlib' ) {
                $decoded = Compress::Zlib::uncompress( $decoded );
            }
            elsif ( $compression eq 'gzip' ) {
                $decoded = Compress::Zlib::memGunzip( $decoded );
            }

            @element_ids = unpack 'V*', $decoded;
        }

        unless (@element_ids) {
            @element_ids = map { $_->att('gid') } $data->children('tile');
        }

        my @rows;
        my $it = natatime $self->width, @element_ids;
        my $y = 0;

        while ( my @row = $it->() ) {
            my $x = 0;

            push @rows, [
                map {
                    Games::TMX::Parser::Cell->new(
                        x     => $x++,
                        y     => $y,
                        tile  => $self->get_tile($_),
                        layer => $self
                    )
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
        my $cell = $_;
        my $tile = $cell->tile;
        $tile && exists $tile->properties->{$prop};
    } $self->all_cells;
}

sub get_cell {
    my ($self, $col, $row) = @_;
    return $self->rows->[$row]->[$col];
}

sub all_cells { return map { @$_ } @{ shift->rows } }

1;
