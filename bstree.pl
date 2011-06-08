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

my $help = q{
a $val1 $val2 ..  : add 
r $times          : add random values
d $val            : delete
s $val            : search
p                 : print
f                 : flatten
dump $file_name   : dump
size $size        : size
flush             : flush
q                 : quit
};

my %response = (
                a => sub {$tree->add(@_)->print},
                q => sub {undef},
                p => sub {$tree->print},
                s => sub {$tree->search_say(@_)},
                f => sub {$tree->flatten_say},
                r => sub {$tree->add_random($_[0])->print},
                flush => sub {$tree->flush->print},
            );

while(my $line = prompt '> ') {
    my ($cmd, @val) = split /\s/, $line;
    $cmd or next;
    my $res = $response{$cmd} or print $help and next;
    defined $res->(@val) or last;
}

1;
