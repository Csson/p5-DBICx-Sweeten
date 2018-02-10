use 5.20.0;
use strict;
use warnings;

package DBIx::Class::Sweeten::ResultSet::Base;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0104';

use Scalar::Util qw/blessed/;
use Data::Dump::Streamer;
use base 'DBIx::Class::ResultSet';

sub db {
    return shift->result_source->schema;
}

sub filter {
    my $self = shift;
    my @args = @_;

    if(scalar @args == 1 and ref $args[0] and blessed($args[0]) and $args[0]->isa('DBIx::Class::Sweeten::Q')) {
        say 'about to search';
        say Dump $args[0]->value;
        return $self->search($args[0]->value);
    }
    else {
        my %args = @args;
        return $self->search(\%args);
    }
}

sub filterattr {
    my $self = shift;
    my %args = @_;

    return $self->search({}, \%args);
}

1;
