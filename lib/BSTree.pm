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

sub append {
    my ($self, $lr, $new) = @_;
    $self->$lr(BSTree->new({val => $new, parent => $self}));
    $self;
}

sub add_one {
    my $self = shift;
    my $new = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    if (defined $val) {
        if ($new < $val) {
            if (defined $left) {
                $left->add_one($new);
            } else {
                $self->append('left', $new);
            }
        } else {
            if (defined $right) {
                $right->add_one($new);
            } else {
                $self->append('right', $new);
            }
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
    $self->add(map {int($max_val * rand)} 1..$times);
}

sub build_from {
    my $class = shift;
    $class->new->add(@_);
}

sub search {
    my ($self, $target_val) = @_;
    defined $target_val or return;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
    $target_val == $val
        ? $self
            : $target_val < $val
                ? (defined $left ? $left->search($target_val) : undef)
                    : (defined $right ? $right->search($target_val) : undef);
}

sub search_say {
    my ($self, $target) = @_;
    say $self->search($target)
        ? "your tree has the element $target"
            : "your tree does not have the elemnt $target";
}

sub delete {
    my ($self, $target_val) = @_;

    defined $target_val or say "target value is not defined." and return $self;
    my $target = $self->search($target_val);
    defined $target or say "$target_val is not found." and return $self;
    my ($val, $left, $right, $parent) = map {$target->$_} qw/val left right parent/;
    if (defined $parent) {
        if (defined $left) {
            my $max = $left->max_node;
            $target->val($max->val);
            my $max_lr = $max->lr;
            $max->parent->$max_lr(undef);

        } else {
            if (defined $right) {
                my $max = $right->max_node;
                my $max_lr = $max->lr;
                $max->parent->$max_lr(undef);
                $target->val($max->val);
            } else {
                my $lr = $target->lr;
                $parent->$lr(undef);
            }
        }
    } else {
        if (defined $left) {
            my $max = $left->max_node;
            if ($left->val == $max->val) {
                $target->val($max->val);
                $target->left($max->left);
                $max->left->parent($target);
            }
        } else {
            $target->copy_from($right);
        }
    }
    $self;
}

sub flush {
    my $self = shift;
    $self->val(undef);
    $self->left(undef);
    $self->right(undef);
    $self;
}

sub to_hash {
    my $self = shift;
    my $h = {
             V => $self->val,
             LR => $self->lr,
         };
    my $p = $self->parent;
    $h->{P} = $p->val if defined $p;
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
    $self->flatten_say;
    my $h = $self->to_hash;
    say JSON::Syck::Dump $h;
    say YAML::Dump $h;
    $self;
}

sub max_node {
    my $self = shift;
    my ($val, $left, $right) = map {$self->$_} qw/val left right/;
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

sub copy_from {
    my ($self, $target) = @_;
    $self->$_($target->$_) for qw/val left right/;
}

sub to_json {
    my $self = shift;
    JSON::Syck::Dump($self->to_hash);
}

sub to_yaml {
    my $self = shift;
    YAML::Dump($self->to_hash);
}

1;
