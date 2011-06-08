use strict;
use warnings;
use Perl6::Say;
use JSON::Syck;
use YAML;
use List::Util qw/reduce/;
use List::MoreUtils qw/uniq/;
no warnings 'once';

use IO::Prompt;
use BSTree;

# scalar @ARGV >= 2 or die 'input "perl bstree.pl $max_val $nodes"';
# my ($max_val, $nodes) = @ARGV;
# my ($max_val, $nodes) = @ARGV;
# say 'Generating an array:';

# my @orig = map {int($max_val * rand)} 1..$nodes;
# my @uniq = uniq @orig;
# # my @sorted = sort {$a <=> $b} @uniq;
# # my @reverse = reverse @sorted;

# say JSON::Syck::Dump [@orig];

# say 'Translate to Binary Search Tree:';

# my $tree = BSTree->build_from(@uniq);
# $tree->print;

# say 'Flatten the tree:';
# my @f = $tree->flatten;
# say JSON::Syck::Dump \@f;

# my $k = $tree->search($f[0]);
# # say "KEY:" . $k;

my $tree = BSTree->new;

my %response = (
                h => sub {
                    print q{h : help
a $val1 $val2 ..  : add 
r $times          : add random values
d $val            : delete
s $val            : search
p                 : print
q                 : quit
};
                },
                a => sub {$tree = $tree->add(@_)->print},
                q => sub {last CMD},
                p => sub {$tree->print},
                r => sub {$tree = $tree->add_random($_[0])->print},
            );

CMD:
while(my $line = prompt '> ') {
    my ($cmd, @val) = split /\s/, $line;
    my $res = $response{$cmd} or
        print "invalid input. hit 'h' for help.\n" and next;
    $res->(@val);
}

1;
