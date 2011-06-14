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


sub test_from_yaml {
    my ($tree, $yaml) = @_;
    is_deeply( $tree->to_hash, YAML::Load($yaml));
}


