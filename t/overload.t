use Test::More;
use strict;

use Data::Currency;

my $curr1 = Data::Currency->new(value => 0.01);
my $curr2 = Data::Currency->new(value => 0.99);

cmp_ok($curr1, 'eq', '$0.01', 'stringification');
cmp_ok($curr2, 'eq', '$0.99', 'stringification');
cmp_ok($curr2 + $curr1, 'eq', '$1.00', '+');
cmp_ok($curr1 * 2, 'eq', '$0.02', '*');
cmp_ok($curr2 * 2, 'eq', '$1.98', '*');
cmp_ok($curr1 += 1, 'eq', '$1.01', '+=');
cmp_ok($curr2 -= 0.50, 'eq', '$0.49', '-=');

use Math::Currency;
{
    my $foo = Math::Currency->new(0.01);
    my $foo2 = Math::Currency->new(0.99);
    print STDERR $foo + $foo2."\n";

    my $far = Data::Currency->new(0.01);
    my $far2 = Data::Currency->new(0.99);
    print STDERR $far + $far2."\n";

    use Math::BigInt;
    my $bar = Math::BigInt->new('0.01');
    print STDERR "## ".$bar->badd('0.99')->bstr."\n";

    print STDERR 0.99 + 0.01."\n";
}


done_testing;