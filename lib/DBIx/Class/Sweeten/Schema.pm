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
            croak(caller(1) . " already has a method named <$method>.");
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

    # in MyApp::Schema, instead of inheriting from DBIx::Class::Schema
    use base 'DBIx::Class::Sweeten::Schema';

=head1 DESCRIPTION

DBIx::Class::Sweeten::Schema adds method accessors for all resultsets.

In short, instead of this:

    my $schema = MyApp::Schema->connect(...);
    my $result = $schema->resultset('Author');

You can do this:

    my $schema = MyApp::Schema->connect(...);
    my $result = $schema->Author;

=head2 What is returned?

The resultset methods can be called in four different ways.

=head3 Without arguments

    # $schema->resultset('Author')
    $schema->Author;

=head3 With a scalar
    # $schema->resultset('Author')->find(5)
    $schema->Author(5);

=head3 With an array reference
    # $schema->resultset('Book')->find({ author => 'J.R.R Tolkien', title => 'The Hobbit' }, { key => 'book_author_title' });
    $schema->Book([book_author_title => { author => 'J.R.R Tolkien', title => 'The Hobbit' }]);

=head3 With anything else
    # $schema->resultset('Author')->search({ last_name => 'Tolkien'}, { order_by => { -asc => 'first_name' }});
    $schema->Author({ last_name => 'Tolkien'}, { order_by => { -asc => 'first_name' }});

=head1 SEE ALSO

=for :list
* L<DBIx::Class::Sweeten>

=cut
