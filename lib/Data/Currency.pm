package Data::Currency;
use strict;
use warnings;
use Moose;

use overload
    '0+'     => sub {shift->value},
    'bool'   => sub {shift->value},
    '""'     => sub {shift->stringify},
    fallback => 1;

use vars qw/$VERSION/;
$VERSION = '0.04002';

use Data::Currency::Types qw(CurrencyCode Format);
use MooseX::Types::Moose qw(HashRef);
use Locale::Currency;
use Locale::Currency::Format;
use Carp;

has code => (
    is => 'rw',
    isa => CurrencyCode,
    default => 'USD'
);
has format => (
    is => 'rw',
    isa => Format,
    default => 'FMT_COMMON'
);
has value => (
    is => 'rw',
    isa => 'Num',
    default => 0
);

sub BUILDARGS {
    my ($class, @args) = @_;

    if(@args == 1 && (!is_HashRef($args[0]))) {
        return { value => $args[0] };
    } elsif(scalar(@args) % 2 == 0) {
        return { @args };
    } elsif(scalar(@args) % 3 == 0) {
        return { value => $args[0], code => $args[1], format => $args[2] };
    }

    return $args[0];
}

sub name {
    my ($self) = @_;
    my $name = Locale::Currency::code2currency($self->code);

    ## Fix for older Locale::Currency w/mispelled Candian
    $name =~ s/Candian/Canadian/;

    return $name;
};

*as_string = \&stringify;

sub stringify {
    my $self = shift;
    my $format = shift || $self->format;
    my $code = $self->code;
    my $value = $self->value;

    if (!$format) {
        $format = 'FMT_COMMON';
    };

    ## funky eval to get string versions of constants back into the values
    eval '$format = Locale::Currency::Format::' .  $format;

    croak 'Invalid currency code:  ' . ($code || 'undef')
        unless is_CurrencyCode($code);

    return _to_utf8(
        Locale::Currency::Format::currency_format($code, $value, $format)
    );
};

sub _to_utf8 {
    my $value = shift;

    if ($] >= 5.008) {
        require utf8;
        utf8::upgrade($value);
    };

    return $value;
};

1;
__END__

=head1 NAME

Data::Currency - Container class for currency conversion/formatting

=head1 SYNOPSIS

    use Data::Currency;

    my $price = Data::Currency->new(value => 1.2. code => 'USD');
    # or
    my $price = Data::Currency->new(1.2); # defaults to USD
    print $price;            # 1.20 USD
    print $price->code;      # USD
    print $price->format;    # FMT_SYMBOL
    print $price->as_string; # 1.20 USD
    print $price->as_string('FMT_SYMBOL'); # $1.20

=head1 DESCRIPTION

The Data::Currency module provides basic currency formatting:

    my $price = 1.23;
    my $currency = Data::Currency->new($price);

    print $currency->convert('CAD')->as_string;

Each Data::Currency object will stringify to the original value except in string
context, where it stringifies to the format specified in C<format>.

=head1 CONSTRUCTOR

=head2 new

=over

=item Arguments: $price [, $code, $format] || \%options

=back

To create a new Data::Currency object, simply call C<new> and pass in the
price to be formatted:

    my $currency = Data::Currency->new(10.23);

    my $currency = Data::Currency->new({
        value  => 1.23,
        code   => 'CAD',
        format => 'FMT_SYMBOL',
    });

You can also pass in the default currency code and/or currency format to be
used for each instance. If no code or format are supplied, future calls to
C<as_string> and C<convert> will use the default format and code values.

The following defaults are set when Data::Currency is loaded:

    value:  0
    code:   USD
    format: FMT_COMMON

=head1 ATTRIBUTES

=head2 code

Gets/sets the three letter currency code for the current currency object.

=head2 format

Gets/sets the format to be used when C<as_string> is called. See
L<Locale::Currency::Format|Locale::Currency::Format> for the available
formatting options.

=head2 name

Returns the currency name for the current objects currency code. If no
currency code is set the method will die.

=head2 value

Returns the original price value given to C<new>.

=head1 METHODS

=head2 stringify

Sames as C<as_string>.

=head2 as_string

Returns the current objects value as a formatted currency string.

=head1 SEE ALSO

L<Locale::Currency>, L<Locale::Currency::Format>,
L<Finance::Currency::Convert::WebserviceX>

=head1 AUTHOR

    Christopher H. Laco
    CPAN ID: CLACO
    claco@chrislaco.com
    http://today.icantfocus.com/blog/
