package Games::TMX::Parser::Map;

use Moo;
use File::Spec;
use Games::TMX::Parser::Layer;
use Games::TMX::Parser::TileSet;
use XML::Twig;

extends 'Games::TMX::Parser::MapElement';

use namespace::clean;

has _dir => ( is => 'ro', default => '.' );

has layers => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            map {
                $_->att('name') => Games::TMX::Parser::Layer->new(
                    el => $_,
                    map => $_[0],
                )
            } $_[0]->children('layer')
        };
    },
);

has tilesets => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my @sets;

        for my $set ( $_[0]->children('tileset') ) {
            if ( ! $set->children && $set->att('source') ) {
                my $twig = XML::Twig->new;

                $twig->parsefile(
                    File::Spec->catfile(
                        $_[0]->_source_dir,
                        $set->att('source'),
                    )
                );

                push @sets, Games::TMX::Parser::TileSet->new(
                    el        => $twig->root,
                    first_gid => $set->att('firstgid'),
                );
            }
            else {
                push @sets, Games::TMX::Parser::TileSet->new( el => $set );
            }
        }

        return \@sets;
    },
);

has tiles_by_id => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my @tiles = map { @{ $_->tiles } } @{ $_[0]->tilesets };
        return { map { $_->id => $_ } @tiles };
    },
);

for my $name (qw( width height tile_width tile_height )) {
    my $attribute = $name;
    $attribute =~ s/_//g;
    has $name => (
        is      => 'ro',
        lazy    => 1,
        default => sub { shift->att($attribute) },
    );
}

sub get_layer { shift->layers->{ +pop } }

sub get_tile  { shift->tiles_by_id->{ +pop } }

1;
