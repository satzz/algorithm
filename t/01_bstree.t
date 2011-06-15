#!/usr/bin/perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use BSTree;
use Data::Dumper;

my $tree = BSTree->new;

#add
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

$tree->delete(5);
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

$tree->delete(1);
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

$tree->delete(7);
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

$tree->delete(3);
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

$tree->delete(1);
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




warn $tree->to_yaml;




sub test_from_yaml {
    my ($tree, $yaml) = @_;
    is_deeply( $tree->to_hash, YAML::Load($yaml));
}


