package Games::TMX::Parser::Cell;

use Moose;

has [qw(x y)] => (is => 'ro', isa => 'Int', required => 1);

has tile => (is => 'ro');

has layer => (is => 'ro', required => 1, weak_ref => 1, handles => [qw(
    get_cell width height
)]);

my %Dirs      = map { $_ => 1 } qw(below left right above);
my %Anti_Dirs = (below => 'above', left => 'right', right => 'left', above => 'below');

sub left  { shift->neighbor(-1, 0) }
sub right { shift->neighbor( 1, 0) }
sub above { shift->neighbor( 0,-1) }
sub below { shift->neighbor( 0, 1) }

sub xy { ($_[0]->x, $_[0]->y) }

sub neighbor {
    my ($self, $dx, $dy) = @_;
    my $x = $self->x + $dx;
    my $y = $self->y + $dy;
    return undef if $x < 0            || $y < 0;
    return undef if $x > $self->width || $y > $self->height;
    return $self->get_cell($x, $y);
}

sub seek_next_cell {
    my ($self, $dir) = @_;
    my %dirs = %Dirs;
    delete $dirs{$Anti_Dirs{$dir}} if $dir;
    for my $d (keys %dirs) {
        my $c = $self->$d;
        return [$c, $d] if $c && $c->tile;
    }
    return undef;
}

1;
