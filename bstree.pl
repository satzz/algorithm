use strict;
use warnings;
use Perl6::Say;
use JSON::Syck;
use YAML;
use List::Util qw/reduce/;
use List::MoreUtils qw/uniq/;
no warnings 'once';

use Data::Dumper;
use IO::Prompt;
use BSTree;

my $tree = BSTree->new;

my %response = (
                h => sub {
                    print q{h : help
a $val1 $val2 ..  : add 
r $times          : add random values
d $val            : delete
dump $file_name   : dump
s $val            : search
p                 : print
f                 : flatten
q                 : quit
};
                },
                a => sub {$tree = $tree->add(@_)->print},
                q => sub {undef},
                p => sub {$tree->print},
                f => sub {$tree->flatten_say},
                r => sub {$tree = $tree->add_random($_[0])->print},
            );

while(my $line = prompt '> ') {
    my ($cmd, @val) = split /\s/, $line;
    my $res = $response{$cmd} or
        print "invalid input. hit 'h' for help.\n" and next;
    defined $res->(@val) or last;
}

1;
