use 5.20.0;
use warnings;

package DBIx::Class::Sweeten::Q;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0104';

use overload '&' => "do_and", '|' => 'do_or';
use Mo;
use Data::Dump::Streamer;
use experimental qw/signatures postderef/;

has value => ();

sub do_and($self, $other, $swap) {
    say '- AND -';
    say Dump $self->value;
    say Dump $other->value;
    say ' // AND';
    my $new = DBIx::Class::Sweeten::Q->new(value => [-and => [$self->value->@*, $other->value->@* ]]);
    return $new;
}

sub do_or($self, $other, $swap) {
    say '- OR -' . $swap;
    say 'self value ref : ' . ref $self->value;
    say 'other value ref: ' . ref $other->value;
    say Dump $self->value;
    say '      - ';
    say Dump $other->value;
    say '===';
    my $new_value = [-or => { $self->value->@*, $other->value->@* }];
    say Dump $new_value;

    my $new = DBIx::Class::Sweeten::Q->new(value => $new_value);
    say 'ref: ' . ref $new;
    say Dump $new->value;
    say ' // OR';
    return $new;
}

1;
