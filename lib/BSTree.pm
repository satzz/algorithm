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
    my $t = shift->new({val => shift});
    if (scalar @_) {
        $t->left(shift);
        $t->right(shift);
    }
    $t;
}

sub add {
    my $self = shift;
    my $new = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    defined $val
        ? ($new < $val
           ? (defined $left
              ? BSTree->create($val, $left->add($new), $right)
              : BSTree->create($val, BSTree->create($new), $right))
           : (defined $right
              ? BSTree->create($val, $left, $right->add($new))
              : BSTree->create($val, $left, BSTree->create($new))))
            : BSTree->create($new);
}

sub build_from {
    reduce {$a->add($b)} (shift->new, @_);
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

sub print {
    my $h = shift->to_hash;
    say JSON::Syck::Dump $h;
    say YAML::Dump $h;
}

sub search {
    my ($self, $target) = @_;
    defined $target or return;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    $target eq $val
        ? $self
            : $target < $val
                ? (defined $left ? $left->search($target) : undef)
                    : (defined $right ? $right->search($target) : undef);
}

sub delete {
    my ($self, $target) = @_;
    defined $target or return;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
}

1;

