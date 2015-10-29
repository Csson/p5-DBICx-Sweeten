use strict;
use warnings;

package DBIx::Class::Sweeten::Schema;

# VERSION
# ABSTRACT: Short intro

use parent 'DBIx::Class::Schema';
use Carp qw/croak/;

our $dbix_class_sweeten_methods_created = 0;

sub connect {
    my $self = shift->next::method(@_);

    if(!$dbix_class_sweeten_methods_created) {
        $self->_dbix_class_sweeten_create_methods();
    }
    return $self;
}

sub _dbix_class_sweeten_create_methods {
    my $self = shift;

    no strict 'refs';
    for my $source (sort $self->sources) {
        (my $method = $source) =~ s{::}{_}g;

        if($self->can($method)) {
            croak(caller(1) . " already has a method named <$source>.");
        }

        *{ caller(1) . "::$method" } = sub {
            my $rs = shift->resultset($source);

            return !scalar @_                  ? $rs
                 : defined $_[0] && !ref $_[0] ? $rs->find(@_)
                 : ref $_[0] eq 'ARRAY'        ? $rs->find(@$_[1..$#_], { key => $_->[0] })
                 :                               $rs->search(@_)
                 ;
        };
    }
    $dbix_class_sweeten_methods_created = 1;

}

1;

__END__

=pod

=head1 SYNOPSIS

    use DBIx::Class::Sweeten::Schema;

=head1 DESCRIPTION

DBICx::Sweeten::Schema is ...

=head1 SEE ALSO

=cut
