use strict;
use warnings;

package DBICx::Sweeten::Schema;

# VERSION
# ABSTRACT: Short intro

use base 'DBIx::Class::Schema';

sub connect {
    my $self = shift->next::method(@_);

    {
        no strict 'refs';
        for my $source ($self->sources) {
            $source =~ s{::}{_}g;

            *{ __PACKAGE__ . "::_$source"} = sub {
                my $rs = shift->resultset($source);

                return !scalar @_                  ? $rs
                     : defined $_[0] && !ref $_[0] ? $rs->find(@_)
                     : ref $_[0] eq 'ARRAY'        ? $rs->find(@$_[1..$#_], { key => $_->[0] })
                     :                               $rs->search(@_)
                     ;
            };
        }
    }
}

1;

__END__

=pod

=head1 SYNOPSIS

    use DBICx::Sweeten::Schema;

=head1 DESCRIPTION

DBICx::Sweeten::Schema is ...

=head1 SEE ALSO

=cut
