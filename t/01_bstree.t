#!/usr/bin/perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use BSTree;
# use Data::Dumper;

my $tree = BSTree->new;

#add
$tree->add(3);
is_deeply($tree->to_hash, 
          {
              'LR' => 'root',
              'P' => '',
              'V' => 3
          }
    );

          



