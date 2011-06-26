package AVL;
use strict;
use warnings;
use base qw/BSTree/;

__PACKAGE__->mk_accessors qw/_height _first_to_refresh/;

sub height { $_[0]->_height }

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->_height(defined $self->val ? 1 : 0);
    bless $self, $class;
    return $self;
}

sub add_one {
    my $self = shift;
    $self->SUPER::add_one(shift);
    my $leaf = $self->last_modified;
    bless $leaf, __PACKAGE__;
    $self->_first_to_refresh($leaf);
    $self->refresh_height;
    $self;
}

sub refresh_height {
    my $self = shift;
    my $target = $self->_first_to_refresh;
    while ($target) {
        my $max = 1;
        my $child_h = {};
        for my $lr (qw/left  right/) {
            my $child = $target->$lr;
            $child_h->{$lr} = $child ? $child->height : 0;
        }

        for my $lr qw/left right/ {
#             my $child = $child_h->$lr or next;
            $max < $child_h->{$lr} + 1 and $max = $child_h->{$lr} + 1;
        }
        $target->_height($max);
        $target = $target->parent;
    }
    $self;
}


sub remove_node {
    my $self = shift;
    $self->SUPER::remove_node;
    my $first = $self;
    if (my $left = $self->left) {
        $first = $left->max_node || $left;
    }
    $first->refresh_height;
    return $self;
}

sub  is_valid {

}

sub rotate {
    my ($self, $direction)  = @_;
    my $opp = __PACKAGE__->opposite($direction) or return $self;

    my $lr = $self->lr;
    if (my $parent = $self->parent) {
        my $child = $self->$opp;
        $parent->$lr($child);
        if ($child) {
            $child->$direction($self);
            $child->parent_weaken($parent);
            $self->parent_weaken($child);

            my $grand_child = $child->$direction;
            $self->$opp($grand_child);
            $grand_child and $grand_child->parent($self);
        }
    }
    return $self;
}

sub opposite {
    my ($class, $direction) = @_;
    $direction eq 'left' ? `right` :
    $direction eq 'right' ? `left` :
    undef;
}

1;
