package Games::TMX::Parser::Tile;

use Moose;

has id      => (is => 'ro', isa => 'Int', required => 1);
has tileset => (is => 'ro', weak_ref => 1, required => 1);

has properties => (is => 'ro', isa => 'HashRef', default => sub { {} });

sub get_prop {
    my ($self, $name) = @_;
    return $self->properties->{$name};
}

1;
