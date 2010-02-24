#!perl -wT
# $Id$
use strict;
use warnings;

BEGIN {
    use lib 't/lib';
    use Test::More;
    use Scalar::Util qw/refaddr/;

    eval 'use Test::MockObject 1.07';
    if (!$@) {
        Test::MockObject->fake_module('Finance::Currency::Convert::WebserviceX' => (
            new => sub {return bless {}, shift},
            convert => sub {return $_[1]+1.00}
        ));

        Test::MockObject->fake_module('MyConverterClass' => (
            new => sub {return bless {}, shift},
            convert => sub {return $_[1]+2.00}
        ));
    };

    use_ok('Data::Currency');
};


## check overloads
{
    my $currency = Data::Currency->new(1);
    cmp_ok($currency->code, 'eq', 'USD', 'code defaults to USD');
    is($currency + 1, 2, 'overloads as numeric');
    ok($currency, 'overloads boolean');
    is("$currency", '$1.00', 'overloads string');
    cmp_ok($currency, '==', 1, 'overloads ==');
};


## as_string/stringify with format
{
    my $currency = Data::Currency->new;
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 0, 'value was set');
    is($currency->stringify('FMT_STANDARD'), '0.00 USD', 'stringify to value');
    is($currency->code, 'USD', 'code is set');
    is($currency->format, 'FMT_COMMON', 'format is not set');
    is($currency->name, 'US Dollar', 'got name');
    is($currency->converter, undef, 'converter no defined');
};


## croak as_string/stringify with no code
{
    my $currency = Data::Currency->new;
    isa_ok($currency, 'Data::Currency');
    delete $currency->{'code'};
    local $Data::Currency::__cag_code = undef;
    
    eval {
        $currency->stringify;
    };
    like($@, qr/invalid currency code/i);
};


## croak as_string/stringify with bad code
{
    my $currency = Data::Currency->new;
    isa_ok($currency, 'Data::Currency');
    $currency->{'code'} = 'BAD';

    eval {
        $currency->stringify;
    };
    like($@, qr/invalid currency code/i);
};

## default formats USD properly
{
    my $currency = Data::Currency->new(1.23);

    is($currency->stringify, '$1.23');
};


## create with no value
{
    my $currency = Data::Currency->new;
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 0, 'value was set');
    is($currency->stringify, '$0.00', 'stringify to value');
    is($currency->code, 'USD', 'code is set');
    is($currency->format, 'FMT_COMMON', 'format is not set');
    is($currency->name, 'US Dollar', 'got name');
    is($currency->converter, undef, 'converter not defined');
};


## create new with no options
{
    my $currency = Data::Currency->new(1.23);
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 1.23, 'value was set');
    is($currency->stringify, '$1.23', 'stringify to value');
    is($currency->code, 'USD', 'code is set');
    is($currency->format, 'FMT_COMMON', 'format is set');
    is($currency->name, 'US Dollar', 'got name');
    is($currency->converter, undef, 'converter no defined');
};


## create new with code/format
{
    my $currency = Data::Currency->new(1.23, 'CAD', 'FMT_STANDARD');
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 1.23, 'value was set');
    is($currency->stringify, '1.23 CAD', 'stringify to string');
    is($currency->code, 'CAD', 'code was set');
    is($currency->format, 'FMT_STANDARD', 'format was set');
    is($currency->converter, undef, 'converter not defined');
};


## create new with code/format as a hash
{
    my $currency = Data::Currency->new({
        value  => 1.23,
        code   => 'CAD',
        format => 'FMT_STANDARD'
    });
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 1.23, 'value was set');
    is($currency->stringify, '1.23 CAD', 'stringify to string');
    is($currency->code, 'CAD', 'code was set');
    is($currency->format, 'FMT_STANDARD', 'format was set');
    is($currency->converter, undef, 'converter not defined');
};

## croak when bad currency code is set in new
{
    eval {
        my $currency = Data::Currency->new(value => 1.23, code => 'BAD');
    };
    like($@, qr/is not a valid/i);
};


## create and set code/format
{
    my $currency = Data::Currency->new(1.23);
    isa_ok($currency, 'Data::Currency');
    is($currency->value, 1.23, 'value was set');
    is($currency->stringify, '$1.23', 'stringify to string');
    is($currency->code, 'USD', 'code is set');
    is($currency->converter, undef, 'converter no defined');

    $currency->code('CAD');
    is($currency->code, 'CAD', 'code set');

    $currency->format('FMT_STANDARD');
    is($currency->format, 'FMT_STANDARD', 'format set');

    is($currency->stringify, '1.23 CAD', 'stringify to string');
};


## tcroak when bad currency code is set
{
    my $currency = Data::Currency->new(1.23);

    eval {
        $currency->code('BAD');
    };
    like($@, qr/not a valid/i);
};


## get name
{
    my $currency = Data::Currency->new(value => 1.23, code => 'JPY');
    isa_ok($currency, 'Data::Currency');
    is($currency->code, 'JPY', 'code was set');
    is($currency->name, 'Yen', 'got name');
};

## test loading of utf8
{
    local $] = 5.007999;

    my $currency = Data::Currency->new(1.23);
    isa_ok($currency, 'Data::Currency');
    is($currency->stringify, '$1.23', 'still got format');
};

done_testing;