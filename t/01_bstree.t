#!/usr/bin/perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use BSTree;
use Data::Dumper;

my $tree = BSTree->new;
test_from_yaml($tree, <<YAML);
---
LR: root
YAML

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

$tree->remove(5);
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

$tree->remove(1);
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

$tree->remove(7);
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

$tree->remove(3);
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

$tree->remove(1);
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

$tree->remove(2);
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

$tree->remove(6);
test_from_yaml($tree, <<YAML);
---
LR: root
R:
  LR: right
  P: 4
  V: 8
V: 4
YAML

$tree->remove(4);
test_from_yaml($tree, <<YAML);
---
LR: root
V: 8
YAML

$tree->remove(8);
test_from_yaml($tree, <<YAML);
---
LR: root
YAML

$tree->add(6);
test_from_yaml($tree, <<YAML);
---
LR: root
V: 6
YAML

$tree->remove(6);
test_from_yaml($tree, <<YAML);
---
LR: root
YAML

$tree->add(1..5)->flush;
test_from_yaml($tree, <<YAML);
---
LR: root
YAML

$tree->flush->add(4,2,1,3)->remove(4);
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

$tree->flush->add(5,4,2,1,3)->remove(4);
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


my $times = 10;
$tree->flush->add_random($times);
my @a = $tree->flatten;
is scalar(@a), $times;


my $val = 2;
$tree->flush->add(($val) x $times);
$tree->remove($val) for (1 .. $times) ;
test_from_yaml($tree, <<YAML);
---
LR: root
YAML





# warn $tree->to_yaml;







sub test_from_yaml {
    my ($tree, $yaml) = @_;
    is_deeply( $tree->to_hash, YAML::Load($yaml));
}


