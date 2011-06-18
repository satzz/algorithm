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
use Data::Dumper;

# use 5.010;


__PACKAGE__->mk_accessors qw/val left right parent/;

sub add_one {
    my $self = shift;
    my $new = shift;
    my $val = $self->val;
    if (defined $val) {
        my $lr = $new < $val ? 'left' : 'right';
        my $child = $self->$lr;
        if (defined $child) {
            $child->add_one($new);
            return $self;
        }
        $self->$lr(BSTree->new({val => $new, parent => $self}));
        return $self;
    }
    $self->val($new);
    return $self;
}

sub add {
    my $self= shift;
    $self->add_one($_) for @_;
    $self;
}

sub add_random {
    my ($self, $times) = @_;
    my $max_val = 100;
    $self->add(map {int($max_val * rand)} 1..$times);
}

sub search {
    my ($self, $target_val) = @_;
    defined $target_val or return;
    my $val = $self->val;
    $target_val == $val and return $self;
    my $lr = ($target_val < $val) ? 'left' : 'right';
    my $child = $self->$lr;
    defined $child and return $child->search($target_val);
}

sub search_say {
    my ($self, $target) = @_;
    say $self->search($target)
        ? "your tree has the element $target"
            : "your tree does not have the elemnt $target";
}

sub flush {
    my $self = shift;
    my $parent = $self->parent;
    if ($parent) {
        my $lr = $self->lr;
        $parent->$lr(undef);
    }
    $self->val(undef);
    $self->left(undef);
    $self->right(undef);
    $self;
}

sub remove {
    my ($self, $target_val) = @_;

    defined $target_val or say "target value is not defined." and return $self;
    my $target = $self->search($target_val);
    defined $target or say "$target_val is not found." and return $self;
    my ($val, $left, $right, $parent) = map {$target->$_} qw/val left right parent/;

    if (defined $parent) {
        my $max =
            defined $left  ? $left->max_node  :
            defined $right ? $right->max_node :
            $target;
        $target->val($max->val);
        my $max_lr = $max->lr;
        $max->parent->$max_lr(undef);
        return $self;
    }

    my $copied;
    if (defined $left) {
        my $max = $left->max_node;
        $target->val($max->val);
        if ($left->val == $max->val) {
            my $max_left = $max->left;
            $target->left($max_left);
            defined $max_left and $max_left->parent($target);
            defined $right and $right->parent($target);
            return $self;
        }
        my $max_lr = $max->lr;
        $max->parent->$max_lr(undef);
        return $self;
    }

    if (defined $right) {
        $target->graft($right);
        return $self;
    }

    $target->val(undef);
    return  $self;
}

sub graft {
    my ($self, $orig) = @_;
    $self->$_($orig->$_) for qw/val left right/;
}

sub max_node {
    my $self = shift;
    my $right = $self->right;
    (defined $right and defined $right->val)
        ? $right->max_node : $self;
}

sub lr {
    my ($self) = @_;
    my $parent = $self->parent;
    defined $parent or return 'root';
    my $left = $parent->left;
    defined $left or return 'right';
    ($left->val == $self->val) ? 'left' : 'right';
}

sub to_hash {
    my $self = shift;
    my ($val, $left, $right, $parent) = map {$self->$_} qw/val left right parent/;
    my $h = { LR => $self->lr };
    defined $val and $h->{V} = $val;
    defined $parent and $h->{P} = $parent->val;
    defined $left and $h->{L} = $left->to_hash;
    defined $right and $h->{R} = $right->to_hash;
    return $h;
}

sub to_array {
    my $self = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    my @a;
    defined $val and push @a, $val;
    defined $left and unshift @a, $left->to_array;
    defined $right and push @a, $right->to_array;
    return [@a];
}

sub to_tree {
    my $self = shift;
    YAML::Dump($self->to_array);
}

sub to_json {
    my $self = shift;
    JSON::Syck::Dump($self->to_hash);
}

sub to_yaml {
    my $self = shift;
    YAML::Dump($self->to_hash);
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
    $self->flatten_say;
    my $h = $self->to_hash;
    say JSON::Syck::Dump $h;
    say YAML::Dump $h;
    $self;
}

1;
