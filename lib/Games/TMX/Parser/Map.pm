package Games::TMX::Parser::Map;

use Moo;
use Types::Standard qw( Str );
use File::Spec;
use XML::Twig;
use Games::TMX::Parser::Layer;
use Games::TMX::Parser::TileSet;

extends 'Games::TMX::Parser::MapElement';

has root_dir => ( is => 'ro', isa => Str, default => '.' );

has twig => ( is => 'ro' );

has width => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('width') },
);

has height => (
    is => 'ro',
    lazy => 1,
    default => sub { shift->att('height') },
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

has layers => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my %layers;
        my $index = 0;

        for my $layer ( $self->children('layer') ) {
            $layers{ $layer->att('name') } = Games::TMX::Parser::Layer->new(
                el    => $layer,
                map   => $self,
                index => $index++,
            );
        }

        return \%layers;
    },
);

has tiles_by_id => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my @tiles = map { @{$_->tiles} } @{ shift->tilesets };
        return {map { $_->id => $_ } @tiles};
    },
);

has tilesets => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my @sets;

        for my $set ( $self->children('tileset') ) {
            if ( ! $set->children && $set->att('source') ) {
                push @sets, Games::TMX::Parser::TileSet->parsefile(
                    File::Spec->catfile( $self->root_dir, $set->att('source') ),
                    first_gid => $set->att('firstgid'),
                    root_dir  => $self->root_dir,
                );
            }
            else {
                push @sets, Games::TMX::Parser::TileSet->new( el => $set );
            }
        }

        return \@sets;
    },
);

sub get_layer { shift->layers->{pop()} }
sub get_tile  { shift->tiles_by_id->{pop()} }

has ordered_layers => (
    is => 'ro',
    init_arg => undef,
    lazy => 1,
    default => sub {
        [ sort { $a->index <=> $b->index } values %{ shift->layers } ];
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
