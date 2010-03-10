use Test::More;
use strict;

use Data::Currency;


# Stringify
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr1, 'eq', '$0.01', 'stringification');
    cmp_ok($curr2, 'eq', '$0.99', 'stringification');
    cmp_ok($curr3, 'eq', '$1.01', 'stringification');
}

# Numify
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr1, '==', 0.01, 'numification');
    cmp_ok($curr2, '==', 0.99, 'numification');
    cmp_ok($curr3, '==', 1.01, 'numification');

    ok($curr1 < $curr2, '< with Data::Currency');
    ok($curr1 < 1, '< with number');

    ok($curr3 > $curr1, '> with Data::Currency');
    ok($curr3 > 1, '> with number');

    ok($curr3 >= Data::Currency->new(1.01), '>= with Data::Currency');
    ok($curr3 >= Data::Currency->new(.01), '>= with Data::Currency (again)');
    ok($curr3 >= 1.01, '>= with number');
    ok($curr3 >= .01, '>= with number (again)');

    ok($curr1 <= Data::Currency->new(1.01), '<= with Data::Currency');
    ok($curr1 <= Data::Currency->new(.01), '<= with Data::Currency (again)');
    ok($curr1 <= 1.01, '<= with number');
    ok($curr1 <= .01, '<= with number (again)');

    ok($curr1 == Data::Currency->new(0.01), '== with Data::Currency');
    ok($curr1 == 0.01, '== with number');
}

# Addition
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr2 + $curr1, 'eq', '$1.00', '+ with Data::Currency');
    cmp_ok($curr2 + 0.01, 'eq', '$1.00', '+ with number');
    cmp_ok($curr2 + .99, 'eq', '$1.98', '+ with number (again)');
}

# Subtraction
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr2 - $curr1, 'eq', '$0.98', '- with Data::Currency');
    cmp_ok($curr3 - $curr2, 'eq', '$0.02', '- with Data::Currency (again)');
    cmp_ok($curr3 - 0.02, 'eq', '$0.99', '- with number');
}

# Multiplication
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr1 * 2, 'eq', '$0.02', '* with number');
    cmp_ok($curr2 * 2, 'eq', '$1.98', '* with number (over a dollar)');
}

# Multiplication
{
    my $curr1 = Data::Currency->new(value => 1.00);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    cmp_ok($curr1 / 2, 'eq', '$0.50', '/ with number');
    cmp_ok($curr2 / 2, 'eq', '$0.50', '/ with number rounding');
}

# +=
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    $curr1 += .99;
    cmp_ok($curr1, 'eq', '$1.00', '+= with number');

    $curr2 += $curr3;
    cmp_ok($curr2, 'eq', '$2.00', '+= Data::Currency');
}

# -=
{
    my $curr1 = Data::Currency->new(value => 0.01);
    my $curr2 = Data::Currency->new(value => 0.99);
    my $curr3 = Data::Currency->new(value => 1.01);

    $curr2 -= 0.50;
    cmp_ok($curr2, 'eq', '$0.49', '-= with number');

    my $currx = Data::Currency->new('1.01');
    my $curry = Data::Currency->new('0.49');
    $currx -= $curry;
    cmp_ok($currx, 'eq', '$0.52', '-= width Data::Currency');
}

done_testing;