use strict;
use warnings;
use YAML;
use BSTree;
use Time::HiRes qw/gettimeofday/;
use Perl6::Say;

my $tree = BSTree->new;

my @length =
qw/
10
30
100
300
1000
3000
10000
/;
my $repeat = 10;
my @time;
for my $length (@length) {
    my ($begin, $end);
    my $sequential = {};
    my $random = {};

    my $max_value = int(sqrt($length));

    for (1..$repeat) {
        say "length: $length \t[$_]";
        $tree->flush;

        $begin = gettimeofday;
        $tree->add(1..$length);
        $end = gettimeofday;
        ($sequential->{insert} ||= 0) += $end - $begin;

        my $val = int($length * rand) +1;
        $begin = gettimeofday;
        $tree->search($val);
        $end = gettimeofday;
        ($sequential->{search} ||= 0) += $end - $begin;

        $begin = gettimeofday;
        $tree->remove_one($val);
        $end = gettimeofday;
        ($sequential->{delete} ||= 0) += $end - $begin;

        $tree->flush;

        my @a = map {int(rand $max_value)} 1..$length;
        $begin = gettimeofday;
        $tree->add(@a);
        $end = gettimeofday;
        ($random->{insert} ||= 0) += $end - $begin;

        my $elm = $a[int($length * rand)];
        $begin = gettimeofday;
        $tree->search($elm);
        $end = gettimeofday;
        ($random->{search} ||= 0) += $end - $begin;

        $begin = gettimeofday;
        $tree->remove_one($elm);
        $end = gettimeofday;
        ($random->{delete} ||= 0) += $end - $begin;

    }
    push @time, {
        length     => $length,
        sequential => $sequential,
        random     => $random,
    };
}
warn YAML::Dump [@time];
