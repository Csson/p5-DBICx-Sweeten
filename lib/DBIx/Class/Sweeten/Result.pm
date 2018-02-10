use 5.10.1;
use strict;
use warnings;

package DBIx::Class::Sweeten::Result;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0104';

use base 'DBIx::Class::Candy';
use String::CamelCase;

sub base {
    (my $base = caller(2)) =~ s{::Schema::Result::.*$}{};

    return $_[1] || "${base}::Schema::Result";
}
sub autotable    { 1 }
sub perl_version { 10 }
sub experimental { [ ] }

sub gen_table {
    my $self = shift;
    my $resultclass = shift;

    $resultclass =~ s{^.*::Schema::Result::}{};
    $resultclass =~ s{::}{__}g;
    $resultclass = String::CamelCase::decamelize($resultclass);

    return $resultclass;
}

1;
