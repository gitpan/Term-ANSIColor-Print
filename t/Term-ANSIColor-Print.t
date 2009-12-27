# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Term-ANSIColor-Print.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok('Term::ANSIColor::Print') };

#########################

my $p = Term::ANSIColor::Print->new(
    output => 'return',
    eol    => '',
);

my $s = $p->green_on_white('x');

my @char_asciis = map { ord $_ } split //, $s;

my @expect_asciis = qw(
    27  91  57  50  109
    27  91  49  48  55  109
    120 
    27  91  48  109
);

is_deeply( \@char_asciis, \@expect_asciis, 'correct green on white markup' );

