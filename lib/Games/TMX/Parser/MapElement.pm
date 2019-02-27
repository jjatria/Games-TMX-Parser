package Games::TMX::Parser::MapElement;

use Moose;

has el => (is => 'ro', required => 1, handles => [qw(
    att att_exists first_child children print
)]);

1;
