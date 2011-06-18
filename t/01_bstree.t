#!/usr/bin/perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use BSTree;
use Data::Dumper;

my $tree = BSTree->new;
is_null($tree);

$tree->add(3);
test_from_yaml($tree, <<YAML);
---
LR: root
V: 3
YAML

$tree->add(1);
test_from_yaml($tree, <<YAML);
---
L:
  LR: left
  P: 3
  V: 1
LR: root
V: 3
YAML

$tree->add(2);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(5);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(1);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(7);
test_from_yaml($tree, <<YAML);
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

$tree->add(1);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(3);
# TODO:parent test
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(1);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(2);
test_from_yaml($tree, <<YAML);
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

$tree->remove_one(6);
test_from_yaml($tree, <<YAML);
---
LR: root
R:
  LR: right
  P: 4
  V: 8
V: 4
YAML

$tree->remove_one(4);
test_from_yaml($tree, <<YAML);
---
LR: root
V: 8
YAML

$tree->remove_one(8);
is_null($tree);

$tree->add(6);
test_from_yaml($tree, <<YAML);
---
LR: root
V: 6
YAML

$tree->remove_one(6);
is_null($tree);

$tree->add(1..5)->flush;
is_null($tree);

$tree->flush->add(4,2,1,3)->remove_one(4);
test_from_yaml($tree, <<YAML);
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

$tree->flush->add(5,4,2,1,3)->remove_one(4);
test_from_yaml($tree, <<YAML);
---
L:
  L:
    L:
      LR: left
      P: 2
      V: 1
    LR: left
    P: 3
    V: 2
  LR: left
  P: 5
  V: 3
LR: root
V: 5
YAML




my $times = 5;
my $max_val = 100;
my @a = 1..$times;
$tree->flush->add(@a)->remove(@a);
is_null($tree);

$tree->flush->add_random($times);
@a = $tree->flatten;
is scalar(@a), $times;
# warn JSON::Syck::Dump [@a];
for my $elm (@a) {
#     warn "remove_one $elm";
#     warn $tree->to_yaml;
    $tree->remove_one($elm);
}
# warn $tree->to_tree;

# test_from_yaml($tree, <<YAML);
# ---
# LR: root
# YAML





my $val = 2;
$tree->flush->add(($val) x $times);
$tree->remove_one($val) for (1 .. $times) ;
is_null($tree);





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


