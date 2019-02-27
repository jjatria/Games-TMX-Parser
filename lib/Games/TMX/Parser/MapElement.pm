package Games::TMX::Parser::MapElement;

use Moo;
use Types::Standard 'HashRef';

use namespace::clean;

has el => (
    is       => 'ro',
    required => 1,
    handles  => [qw(
        att att_exists first_child children print
    )],
);

has properties => (
    is      => 'ro',
    isa     => HashRef,
    default => sub {
        my $props = $_[0]->first_child('properties')
            or return {};

        return {
            map { $_->att('name') => $_->att('value') } $props->children
        };
    },
);

sub get_prop { shift->properties->{ +shift } }

1;
