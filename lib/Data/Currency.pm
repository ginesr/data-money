package Data::Currency;
use strict;
use warnings;
use Moose;

use vars qw/$VERSION/;
$VERSION = '0.04002';

with qw(MooseX::Clone);

use Check::ISA qw(obj);
use Math::BigFloat;

use overload
    '+'     => \&add,
    '-'     => \&subtract,
    '*'     => sub { $_[0]->clone(value => $_[0]->value->copy->bmul($_[1])) },
    '/'     => sub { $_[0]->clone(value => scalar($_[0]->value->copy->bdiv($_[1]))) },
    '+='    => \&add_in_place,
    '-='    => \&subtract_in_place,
    '""'    => sub { shift->stringify },
    fallback => 1;

use Data::Currency::Types qw(Amount CurrencyCode Format);
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
    isa => Amount,
    default => sub { Math::BigFloat->new(0) },
    coerce => 1
);

sub BUILDARGS {
    my ($class, @args) = @_;

    if(@args == 1 && (!is_HashRef($args[0]))) {
        return { value => $args[0] };
    } elsif(scalar(@args) % 2 == 0) {
        return { @args };
    }

    return $args[0];
}

# Liberally jacked from Math::Currency

sub as_float {
    my ($self) = @_;

    return $self->value->copy->bfround( -2 )->bstr;
}

# Liberally jacked from Math::Currency

sub as_int {
    my ($self) = @_;

    (my $str = $self->as_float) =~ s/\.//o;
    $str =~ s/^(\-?)0+/$1/o;
    return $str eq '' ? '0' : $str;
}

sub add {
    my ($self, $num) = @_;

    if(obj($num, 'Data::Currency')) {
        return $self->clone(value => $self->value->copy->badd($num->value));
    }
    return $self->clone(value => $self->value->copy->badd(Math::BigFloat->new($num)))
}

sub add_in_place {
    my ($self, $num) = @_;

    if(obj($num, 'Data::Currency')) {
        $self->value($self->value->copy->badd($num->value));
    } else {
        $self->value($self->value->copy->badd(Math::BigFloat->new($num)));
    }
    return $self;
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

    if (!$format) {
        $format = 'FMT_COMMON';
    };

    ## funky eval to get string versions of constants back into the values
    eval '$format = Locale::Currency::Format::' .  $format;

    croak 'Invalid currency code:  ' . ($code || 'undef')
        unless is_CurrencyCode($code);

    return _to_utf8(
        Locale::Currency::Format::currency_format($code, $self->as_float, $format)
    );
};

sub subtract {
    my ($self, $num) = @_;

    if(obj($num, 'Data::Currency')) {
        return $self->clone(value => $self->value->copy->bsub($num->value));
    }
    return $self->clone(value => $self->value->copy->bsub(Math::BigFloat->new($num)))
}

sub subtract_in_place {
    my ($self, $num) = @_;

    if(obj($num, 'Data::Currency')) {
        $self->value($self->value->copy->bsub($num->value));
    } else {
        $self->value($self->value->copy->bsub(Math::BigFloat->new($num)));
    }

    return $self;
}


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

=head1 OPERATOR OVERLOADING

Data::Currency overrides some operators.  It is important to note which
operators change the object's value and which return new ones.  Addition and
subtraction operators accept either a Data::Currency argument or a normal
number via scalar.  Others expect only a number.

Data::Currency overloads the following operators:

=over 4

=item +

Handled by the C<add> method.  Returns a new Data::Currency object.

=item -

Handled by the C<subtract> method.  Returns a new Data::Currency object.

=item *

Returns a new Data::Currency object.

=item +=

Handled by the C<add_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Currency argument or a normal number.

=item -=

Handled by the C<subtract_in_place> method.  Modifies the left-hand object's value.
Works with either a Data::Currency argument or a normal number.

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

=head2 add($amount)

Adds the specified amount to this Data::Currency object and returns a new
Data::Currency object.  You can supply either a number of a Data::Currency
object.  Note that this B<does not> modify the existing object.

=head2 add_in_place($amount)

Adds the specified amount to this Data::Currency object, modifying it's value.
You can supply either a number of a Data::Currency object.  Note that this
B<does> modify the existing object.

=head2 as_int

Returns the object's value "in pennies" (in the US at least).  It
strips the value of formatting using C<as_float> and of any decimals.

=head2 as_float

Returns objects value without any formatting.

=head2 subtract($amount)

Subtracts the specified amount to this Data::Currency object and returns a new
Data::Currency object. You can supply either a number of a Data::Currency
object. Note that this B<does not> modify the existing object.

=head2 subtract_in_place($amount)

Subtracts the specified amount to this Data::Currency object, modifying it's
value. You can supply either a number of a Data::Currency object. Note that
this B<does> modify the existing object.

=head2 clone(%params)

Clone this Data::Currency object and creates a new one.  You may optionally
specify some of the attributes to overwrite.

  $curr->clone({ value => 100 }); # Clones all fields but changes value to 100

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
