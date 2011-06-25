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
use Scalar::Util qw/weaken/;

# use 5.010;


__PACKAGE__->mk_accessors qw/val left right parent/;

sub add_one {
    my $self = shift;
    my $new = shift;
    my $target = $self;
LOOP:
    while (1) {
        my $val = $target->val;

        if (defined $val) {
            my $lr = $new < $val ? 'left' : 'right';
            my $child = $target->$lr;
            if ($child) {
                $target = $child;
                next LOOP;
            }
            my $new_node = BSTree->new({val => $new});
            $new_node->parent_weaken($target);
            $target->$lr($new_node);
            last LOOP;
        }
        $target->val($new);
        last LOOP;
    }
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
    my $target = $self;
LOOP:
    while (1) {
        defined $target_val or last LOOP;
        my $val = $target->val;
        $target_val == $val and return $target;
        my $lr = ($target_val < $val) ? 'left' : 'right';
        my $child = $target->$lr;
        $child and $target = $child and next LOOP;
    }
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

sub init {
    my $self = shift;
    $self->flush->add(@_);
}

sub remove_one {
    my ($self, $target_val) = @_;

    defined $target_val
        or say "target value is not defined."
            and return $self;
    my $target = $self->search($target_val)
        or say "$target_val is not found."
            and return $self;
    my ($val, $left, $right, $parent) = map {$target->$_} qw/val left right parent/;

    my $child = $left || $right;

    if ($left && ($right || !$parent)) {
        my $max = $left->max_node;
        $child = $max->left;
        $target->val($max->val);
        $target = $max;
    }

    if ($parent || $left) {
        my $lr = $target->lr;
        $parent = $target->parent;
        $parent->$lr($child);
        $child and $child->parent_weaken($parent);
        return $self;
    }

    if ($right) {
        $target->graft($right);
        return $self;
    }

    $target->val(undef);
    return  $self;
}

sub remove {
    my $self= shift;
    $self->remove_one($_) for @_;
    $self;
}


sub graft {
    my ($self, $orig) = @_;
    $self->val($orig->val);
    for my $lr(qw/left right/) {
        my $child = $orig->$lr;
        $self->$lr($child);
        $child and $child->parent_weaken($self);
    }
}

sub max_node {
    my $self = shift;
    my $target = $self;
LOOP:
    while (1) {
        my $right = $target->right;
        if ($right and defined $right->val) {
            $target = $right;
            next LOOP;
        }
        return $target;
    }
}

sub lr {
    my ($self) = @_;
    my $parent = $self->parent;
    $parent or return 'root';
    my $left = $parent->left;
    $left or return 'right';
    $left eq $self ? 'left' : 'right';
}

sub parent_weaken {
    my ($self, $parent) = @_;
    $self->parent($parent);
    weaken($self->{parent});
}

sub to_hash {
    my $self = shift;
    my ($val, $left, $right, $parent) = map {$self->$_} qw/val left right parent/;
    my $h = { LR => $self->lr };
    defined $val and $h->{V} = $val;
    $parent and $h->{P} = $parent->val;
    $left and $h->{L} = $left->to_hash;
    $right and $h->{R} = $right->to_hash;
    return $h;
}

sub to_array {
    my $self = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    my @a;
    defined $val and push @a, $val;
    $left and unshift @a, $left->to_array;
    $right and push @a, $right->to_array;
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
    ($left ? $left->flatten : (),
     $self->val,
     $right ? $right->flatten : ());
}

sub flatten_say {
    my $self = shift;
    say JSON::Syck::Dump [$self->flatten];
}

sub is_valid {

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
