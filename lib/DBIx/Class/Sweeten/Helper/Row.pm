use 5.10.1;
use strict;
use warnings;

package DBIx::Class::Sweeten::Helper::Row;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0104';

use parent 'DBIx::Class::Row';
use String::CamelCase;
use DBIx::Class::Candy::Exports;
export_methods [qw/
    col
    primary
    foreign
    belongs
    unique
    primary_belongs
/];

sub col {
    say $_[0] . '/' . $_[1];
    shift->add_columns(shift ,=> shift);
}

sub primary {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    my $normal = {
        has_many => [keys %{ $args->{'_sweeten'}{'has_many'} }],
        might_have => [keys %{ $args->{'_sweeten'}{'might_have'} }],
        has_one => [keys %{ $args->{'_sweeten'}{'has_one'} }],
    };
    my $many_to_many_sources = delete $args->{'_sweeten'}{'across'};
    delete $args->{'_sweeten'};
    $self->add_columns($column_name => $args);
    $self->set_primary_key($self->primary_columns, $column_name);



    for my $type (keys %{ $normal }) {
        for my $other_result_source (@{ $normal->{ $type }}) {
            my $other_class = $self->result_source_to_class($other_result_source);
            my $relation_name = $self->result_source_to_relation_name($other_result_source, 1);
            $self->$type($relation_name, $other_class, $column_name);
        }
    }
    if(defined $many_to_many_sources) {
        for my $across_source (keys %{ $many_to_many_sources}) {
            for my $to_source (keys %{ $many_to_many_sources->{ $across_source } }) {
                my $across_class = $self->result_source_to_class($across_source);
                my $across_relation_name = $self->result_source_to_relation_name($across_source, 1);

                my $to_relation_name = $self->result_source_to_relation_name($to_source, 1);
                my $to_primary_column = $self->result_source_to_relation_name($to_source, 0) . '_id';

                $self->has_many($across_relation_name, $across_class, $column_name);
                $self->many_to_many($to_relation_name, $across_relation_name, $to_primary_column);
            }
        }
    }
}
sub primary_belongs {
    my $self = shift;

    my $column_name = $self->belongs(@_);
    $self->set_primary_key($self->primary_columns, $column_name);

}
sub foreign {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $args->{'is_foreign_key'} = 1;
    $self->add_column($column_name => $args);
}
sub belongs {
    my $self = shift;
    my $other_source = shift;
    my $args = shift;

    my $belongs_to_class = $self->result_source_to_class($other_source);
    my $belongs_to_relation = $self->result_source_to_relation_name($other_source);
    my $column_name = $belongs_to_relation . '_id';

    $self->foreign($column_name => $args);
    $self->belongs_to($belongs_to_relation, $belongs_to_class, $column_name);

    return $column_name;

}

sub unique {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $self->add_columns($column_name => $args);
    $self->add_unique_constraint([ $column_name ]);
}

# this is possible:
# primary book_id => integer many 'UnnecessarilyLong|Thing'
# the pipe denodes where the relation name starts, in this case 'things',
# instead of unnecessarily_long_things
sub result_source_to_relation_name {
    my $self = shift;
    my $result_source_name = shift;
    my $plural = shift || 0;
    my $relation_name = $self->clean_source_name($result_source_name);

    $relation_name =~ s{::}{_}g;
    my @parts = split /\|/, $relation_name, 2;
    $relation_name = $parts[-1];
    $relation_name = String::CamelCase::decamelize($relation_name);

    return $relation_name.($plural && substr ($relation_name, -1, 1) ne 's' ? 's' : '');
}
sub result_source_to_class {
    my $self = shift;
    my $other_result_source = shift;
    $other_result_source =~ s{\|}{};

    # Make it possible to use fully qualified result sources, with a hât.
    return $other_result_source if substr($other_result_source, 0, 1) eq '^';
    return $self->base_namespace($self).$self->clean_source_name($other_result_source);
}
sub base_namespace {
    my $self = shift;
    my $class = shift;
    $self =~ m{^(.*?::Result::)};
    return $1;
}
sub clean_source_name {
    my $self = shift;
    my $source_name = shift;
    $source_name =~ s{^.*?::Result::}{};

    return $source_name;
}

1;
