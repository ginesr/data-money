use Test::More;
use strict;

use Data::Currency;

my $curr1 = Data::Currency->new(value => 0.01);
my $curr2 = Data::Currency->new(value => 0.99);
my $curr3 = Data::Currency->new(value => 1.01);

# Stringify
cmp_ok($curr1, 'eq', '$0.01', 'stringification');
cmp_ok($curr2, 'eq', '$0.99', 'stringification');
cmp_ok($curr3, 'eq', '$1.01', 'stringification');

# Addition
cmp_ok($curr2 + $curr1, 'eq', '$1.00', '+ with Data::Currency');
cmp_ok($curr2 + 0.01, 'eq', '$1.00', '+ with number');
cmp_ok($curr2 + .99, 'eq', '$1.98', '+ with number (again)');

# Subtraction
cmp_ok($curr2 - $curr1, 'eq', '$0.98', '- with Data::Currency');
cmp_ok($curr3 - $curr2, 'eq', '$0.02', '- with Data::Currency (again)');
cmp_ok($curr3 - 0.02, 'eq', '$0.99', '- with number');

# Multiplication
cmp_ok($curr1 * 2, 'eq', '$0.02', '* with number');
cmp_ok($curr2 * 2, 'eq', '$1.98', '* with number (over a dollar)');

# +=
$curr1 += .99;
cmp_ok($curr1, 'eq', '$1.00', '+= with number');
# cmp_ok($curr1 += $curr2, 'eq', '$1.00', '+= Data::Currency');

# -=
$curr2 -= 0.50;
cmp_ok($curr2, 'eq', '$0.49', '-= with number');

$curr3 -= $curr2;
cmp_ok($curr3, 'eq', '$0.52', '-= width Data::Currency');

done_testing;