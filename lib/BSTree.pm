package BSTree;
use strict;
use warnings;

use base qw/Class::Accessor::Fast/;
use Perl6::Say;
no warnings 'once';
use List::Util qw/reduce/;
use Perl6::Say;
use JSON::Syck;
use YAML;


__PACKAGE__->mk_accessors qw/val left right/;

sub create {
    my $class = shift;
    my $t = $class->new;
    my $new = shift;
    defined $new and $t->val($new);
    if (scalar @_) {
        $t->left(shift);
        $t->right(shift);
    }
    $t;
}

sub add_one {
    my $self = shift;
    my $new = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    if (defined $val) {
        if ($new < $val) {
            $self->left
                (defined $left
                 ? $left->add_one($new)
                 : BSTree->create($new));
        } else { 
            $self->right
                (defined $right
                 ?  $right->add_one($new)
                 :  BSTree->create($new));
        }
    } else {
        $self->val($new);
    }
    $self;
}

sub add {
    my $self= shift;
    $self->add_one($_) for @_;
    $self;
}

sub add_random {
    my ($self, $times) = @_;
    my $max_val = 100;
    $self->add(map {int($max_val * rand)} 1..$times)->print;
}

sub build_from {
    my $class = shift;
    $class->new->add(@_)->print;
}

sub to_hash {
    my $self = shift;
    my $h = {
             V => $self->val,
         };
    if (my $left = $self->left) {
        $h->{L} = $left->to_hash;
    }
    if (my $right = $self->right) {
        $h->{R} = $right->to_hash;
    }
    return $h;
}

sub flatten {
    my $self = shift;
    my $left = $self->left;
    my $right = $self->right;
    (defined $left ? $left->flatten : (),
     $self->val, 
     defined $right ? $right->flatten : ());
}

sub flatten_say {
    my $self = shift;
    say JSON::Syck::Dump [$self->flatten];
}

sub print {
    my $self = shift;
    my $h = $self->to_hash;
    say JSON::Syck::Dump $h;
    say YAML::Dump $h;
    $self;
}

sub search {
    my ($self, $target) = @_;
    defined $target or return;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    $target eq $val
        ? 1
            : $target < $val
                ? (defined $left ? $left->search($target) : 0)
                    : (defined $right ? $right->search($target) : 0);
}

sub search_say {
    my ($self, $target) = @_;
    say $self->search($target)
        ? "your tree has the element $target"
            : "your tree does not have the elemnt $target";
}

sub delete {
    my ($self, $target) = @_;
    defined $target or return;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
}

sub flush {
    my $self = shift;
    $self->val(undef);
    $self->left(undef);
    $self->right(undef);
    $self;
}

sub is_leaf {
    my $self = shift;
    ! $self->has_child;
}

sub has_child {
    my $self = shift;
    $self->left and return 1;
    $self->right and return 1;
}

1;
