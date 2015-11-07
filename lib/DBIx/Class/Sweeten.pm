use strict;
use warnings;

package DBIx::Class::Sweeten;

# VERSION
# ABSTRACT: Short intro

1;

__END__

=pod

=head1 SYNOPSIS

    # in MyApp::Schema, instead of inheriting from DBIx::Class::Schema
    use base 'DBIx::Class::Sweeten::Schema';

=head1 DESCRIPTION

DBIx::Class::Sweeten is a collection of modules that can be used to reduce some boilerplate associated with L<DBIx::Class>.

=for :list
* L<DBIx::Class::Sweeten::Schema> - Access resultsets via method calls
* L<DBIx::Class::Sweeten::Result::Base> - Adds a column attribute for easier indexing
* L<DBIx::Class::Sweeten::Result> - DBIx::Class::Candy defaults for result sources
* L<DBIx::Class::Sweeten::ResultSet> - DBIx::Class::Candy defaults for resultsets

=head1 SEE ALSO

=for :list
* L<DBIx::Class>
* L<DBIx::Class::Candy> - Sugar for C<DBIx::Class>
* L<DBIx::Class::Helpers> - More C<DBIx::Class> goodness
* L<DBICx::Shortcuts> - An alternative for C<DBIx::Class::Sweeten::Schema>

=cut
