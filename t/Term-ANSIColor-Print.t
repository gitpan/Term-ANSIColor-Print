# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Term-ANSIColor-Print.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('Term::ANSIColor::Print') };

#########################

my ($str,@char_asciis,@expect_asciis);

my $p = Term::ANSIColor::Print->new(
    output => 'return',
    alias  => {
        happy => 'yellow_on_dark_red',
    },
);

$str = $p->green_on_white('x');

@char_asciis = map { ord $_ } split //, $str;

@expect_asciis = qw(
    27  91  57  50  109
    27  91  49  48  55  109
    120
    27  91  48  109
    10
);

is_deeply( \@char_asciis, \@expect_asciis, 'correct green on white markup' );

$str = $p->green_('x');

@char_asciis = map { ord $_ } split //, $str;

@expect_asciis = qw(
    27 91 57 50 109
    120
    27 91 48 109
);

is_deeply( \@char_asciis, \@expect_asciis, 'correct green with no eol' );

$str = $p->happy('x');

@char_asciis = map { ord $_ } split //, $str;

@expect_asciis = qw(
    27 91 57 51 109
    27 91 52 49 109
    120
    27 91 48 109
    10
);

is_deeply( \@char_asciis, \@expect_asciis, 'correct alias' );

