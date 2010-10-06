use Test::More tests => 1;
use strict;

use Data::Money;

## Explicit undef
{
    my $m = Data::Money->new(value => undef);
    cmp_ok($m->as_string, 'eq', '$0.00', 'Explicit undef makes it a zero');
};

done_testing;
