package Games::TMX::Parser::MapElement;

our $VERSION = '1.000000';

use Moo;
use Types::Standard qw( HashRef );

use namespace::clean;

has el => (
    is => 'ro',
    required => 1,
    handles => [qw(
        att
        att_exists
        first_child
        children
        print
    )],
);

has properties => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    default => sub {
        return {} unless $_[0]->el;

        my $el = $_[0]->first_child('properties') or return {};

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

        return \%props;
    },
);

sub get_prop { shift->properties->{ +shift } }

1;
