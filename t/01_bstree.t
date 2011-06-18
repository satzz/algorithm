#!/usr/bin/perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use BSTree;
use Data::Dumper;
use Perl6::Say;

my $tree = BSTree->new;
is_null($tree);

test_from_yaml($tree->add(3), <<YAML);
---
LR: root
V: 3
YAML

test_from_yaml($tree->add(1), <<YAML);
---
L:
  LR: left
  P: 3
  V: 1
LR: root
V: 3
YAML

test_from_yaml($tree->add(2), <<YAML);
---
L:
  LR: left
  P: 3
  R:
    LR: right
    P: 1
    V: 2
  V: 1
LR: root
V: 3
YAML

$tree->add(7, 5, 8, 4 ,6);
my $all = <<YAML;
---
L:
  LR: left
  P: 3
  R:
    LR: right
    P: 1
    V: 2
  V: 1
LR: root
R:
  L:
    L:
      LR: left
      P: 5
      V: 4
    LR: left
    P: 7
    R:
      LR: right
      P: 5
      V: 6
    V: 5
  LR: right
  P: 3
  R:
    LR: right
    P: 7
    V: 8
  V: 7
V: 3
YAML
test_from_yaml($tree, $all);

my $s = $tree->search(5);
test_from_yaml($tree, $all);
test_from_yaml($s, <<YAML);
---
L:
  LR: left
  P: 5
  V: 4
LR: left
P: 7
R:
  LR: right
  P: 5
  V: 6
V: 5
YAML

test_from_yaml($tree->remove_one(5), <<YAML);
---
L:
  LR: left
  P: 3
  R:
    LR: right
    P: 1
    V: 2
  V: 1
LR: root
R:
  L:
    LR: left
    P: 7
    R:
      LR: right
      P: 4
      V: 6
    V: 4
  LR: right
  P: 3
  R:
    LR: right
    P: 7
    V: 8
  V: 7
V: 3
YAML

test_from_yaml($tree->remove_one(1), <<YAML);
---
L:
  LR: left
  P: 3
  V: 2
LR: root
R:
  L:
    LR: left
    P: 7
    R:
      LR: right
      P: 4
      V: 6
    V: 4
  LR: right
  P: 3
  R:
    LR: right
    P: 7
    V: 8
  V: 7
V: 3
YAML

test_from_yaml($tree->remove_one(7), <<YAML);
---
L:
  LR: left
  P: 3
  V: 2
LR: root
R:
  L:
    LR: left
    P: 6
    V: 4
  LR: right
  P: 3
  R:
    LR: right
    P: 6
    V: 8
  V: 6
V: 3
YAML

test_from_yaml($tree->add(1), <<YAML);
---
L:
  L:
    LR: left
    P: 2
    V: 1
  LR: left
  P: 3
  V: 2
LR: root
R:
  L:
    LR: left
    P: 6
    V: 4
  LR: right
  P: 3
  R:
    LR: right
    P: 6
    V: 8
  V: 6
V: 3
YAML

                
# TODO:parent test


# TODO:parent test
test_from_yaml($tree->remove_one(3), <<YAML);
---
L:
  LR: left
  P: 2
  V: 1
LR: root
R:
  L:
    LR: left
    P: 6
    V: 4
  LR: right
  P: 2
  R:
    LR: right
    P: 6
    V: 8
  V: 6
V: 2
YAML

test_from_yaml($tree->remove_one(1), <<YAML);
---
LR: root
R:
  L:
    LR: left
    P: 6
    V: 4
  LR: right
  P: 2
  R:
    LR: right
    P: 6
    V: 8
  V: 6
V: 2
YAML

test_from_yaml($tree->remove_one(2), <<YAML);
---
L:
  LR: left
  P: 6
  V: 4
LR: root
R:
  LR: right
  P: 6
  V: 8
V: 6
YAML

test_from_yaml($tree->remove_one(6), <<YAML);
---
LR: root
R:
  LR: right
  P: 4
  V: 8
V: 4
YAML

test_from_yaml($tree->remove_one(4), <<YAML);
---
LR: root
V: 8
YAML

is_null($tree->remove_one(8));

test_from_yaml($tree->add(6), <<YAML);
---
LR: root
V: 6
YAML

is_null($tree->remove_one(6));

is_null($tree->add(1..5)->flush);

test_from_yaml($tree->init(4,2,1,3)->remove_one(4), <<YAML);
---
L:
  L:
    LR: left
    P: 2
    V: 1
  LR: left
  P: 3
  V: 2
LR: root
V: 3
YAML

test_from_yaml($tree->init(7,6,5,1,2,4,3)->remove_one(6), <<YAML);
---
L:
  L:
    LR: left
    P: 5
    R:
      LR: right
      P: 1
      R:
        L:
          LR: left
          P: 4
          V: 3
        LR: right
        P: 2
        V: 4
      V: 2
    V: 1
  LR: left
  P: 7
  V: 5
LR: root
V: 7
YAML

test_from_yaml($tree->init(5,4,2,1,3)->remove_one(4), <<YAML);
---
L:
  L:
    LR: left
    P: 2
    V: 1
  LR: left
  P: 5
  R:
    LR: right
    P: 2
    V: 3
  V: 2
LR: root
V: 5
YAML

test_from_yaml($tree->init(5,1,2,4,2)->remove(5), <<YAML);
---
L:
  LR: left
  P: 4
  R:
    LR: right
    P: 1
    R:
      LR: right
      P: 2
      V: 2
    V: 2
  V: 1
LR: root
V: 4
YAML

test_from_yaml($tree->init(2,1,1,3)->remove(2), <<YAML);
---
L:
  LR: left
  P: 1
  V: 1
LR: root
R:
  LR: right
  P: 1
  V: 3
V: 1
YAML

goto HELL;

my $times = 10;
my @a = 1..$times;
$tree->init(@a)->remove(@a);
is_null($tree);

@a = (2) x $times;
$tree->init(@a)->remove(@a);
is_null($tree);

my $max_val = 20;
for(1..10) {
@a = map {int($max_val * rand)} 1..$times;
say JSON::Syck::Dump [@a];

$tree->init(@a);

say $tree->to_tree;
my $old = $tree->to_yaml;
for my $elm (@a) {
#     say "remove $elm";
    $tree->remove($elm);
    my $new = $tree->to_yaml;
#     say JSON::Syck::Dump [$tree->flatten];

    if ($old eq $new) {
        say $old;
        say $new;
    }
    $old = $new;
}
# $tree->remove(@a);
is_null($tree);
}



# $tree->init(@a);
# warn $tree->to_tree;



# $tree->flush->add_random($times);
# @a = $tree->flatten;
# is scalar(@a), $times;
# $tree->remove(@a);
# is_null($tree);




HELL:
print 1;



# warn $tree->to_yaml;

sub is_null {
    my $tree = shift;
    test_from_yaml($tree, <<YAML);
---
LR: root
YAML
}



sub test_from_yaml {
    my ($tree, $yaml) = @_;
    is_deeply( $tree->to_hash, YAML::Load($yaml));
}


