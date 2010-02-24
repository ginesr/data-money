package Data::Currency::Types;

use MooseX::Types -declare => [ qw(CurrencyCode Format) ];

use MooseX::Types::Moose qw(Str);
use Locale::Currency qw(code2currency);

subtype CurrencyCode,
    as Str,
    where { !defined($_) || ($_ =~ /^[A-Z]{3}$/ && defined(code2currency($_))) },
    message { 'String is not a valid 3 letter currency code.' };

enum Format,
    ( qw(FMT_COMMON FMT_HTML FMT_NAME FMT_STANDARD FMT_SYMBOL) );

1;