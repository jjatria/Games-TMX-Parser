package Games::TMX::Parser::TileSet;

use Moo;
use Types::Standard qw( Str );
use List::MoreUtils qw(natatime);
use XML::Twig;
use File::Spec;
use Games::TMX::Parser::Tile;

use namespace::clean;

extends 'Games::TMX::Parser::MapElement';

has root_dir => ( is => 'ro', isa => Str, default => '.' );

has twig => ( is => 'ro' );

has tiles => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $first_gid = $self->first_gid;

        # index tiles with properties

        my %prop_tiles;

        for my $tile ( $self->children('tile') ) {
            my $id = $first_gid + $tile->att('id');
            my $el = $tile->first_child('properties') or next;

            my %props;

            for ( $el->children ) {
                my $type = $_->att('type') // '';
                if ( $type eq 'boolean' ) {
                    $props{ $_->att('name') } = $_->att('value') eq 'true';
                }
                else {
                    $props{ $_->att('name') } = $_->att('value');
                }
            }

            $prop_tiles{$id} = Games::TMX::Parser::Tile->new(
                id         => $id,
                properties => \%props,
                tileset    => $self,
            );
        }

        # create a tile object for each tile in the tileset
        # unless it is a tile with properties
        my @tiles;
        my $it = natatime $self->width, 0 .. $self->tile_count - 1;
        while (my @ids = $it->()) {
            for my $id (@ids) {
                my $gid = $first_gid + $id;
                my $tile = $prop_tiles{$gid} ||
                    Games::TMX::Parser::Tile->new(id => $gid, tileset => $self);
                push @tiles, $tile;
            }
        }
        return [@tiles];
    },
);

has tile_count => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return ($self->width      * $self->height     ) /
               ($self->tile_width * $self->tile_height);
    },
);

has columns => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('columns') },
);

has first_gid => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('firstgid') },
);

has tile_width => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('tilewidth') },
);

has tile_height => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('tileheight') },
);

has width => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->first_child('image')->att('width') },
);

has height => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->first_child('image')->att('height') },
);

has image => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        File::Spec->catfile(
            $self->root_dir, $self->first_child('image')->att('source')
        );
    },
);

sub parsefile {
    my $class = shift;
    my $path  = shift;

    my $twig = XML::Twig->new;
    $twig->parsefile($path);

    return $class->new( el => $twig->root, twig => $twig, @_ );
}

1;
