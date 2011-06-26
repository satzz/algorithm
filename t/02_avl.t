use strict;
use warnings;
use Test::More qw/no_plan/;
use JSON::Syck;
use YAML;
use AVL;
use Data::Dumper;
use Perl6::Say;
use Test::LeakTrace;

BEGIN {use_ok 'AVL'};

my $tree = AVL->new;

is $tree->height, 0;
$tree->init(11);
is $tree->last_modified, $tree;
is $tree->last_modified->height, 1;


# is $tree->height, 1;
# die;


$tree->init(11,8,14,6,9,12,15,4,7,10,13,3,5);

is $tree->height, 5;
is $tree->search(8)->height, 4;
is $tree->search(6)->height, 3;
is $tree->search(4)->height, 2;
is $tree->search(3)->height, 1;
is $tree->search(10)->height, 1;
is $tree->search(9)->height, 2;

die;

$tree->remove(3,5);
is $tree->height, 4;
is $tree->search(8)->height, 3;
is $tree->search(6)->height, 2;
is $tree->search(4)->height, 1;
is $tree->search(10)->height, 1;
is $tree->search(9)->height, 2;

$tree->add(3,2);





# warn Dumper $tree;



