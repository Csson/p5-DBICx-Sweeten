use 5.10.1;
use strict;
use warnings;

package DBIx::Class::Sweeten::Helper::Row;

use parent 'DBIx::Class::Row';
use String::CamelCase;
use DBIx::Class::Candy::Exports;
export_methods [qw/
    col
    primary
    foreign
    unique
    primary_foreign
/];

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0102';

my $relations_to_add = {};
my $seen_table = {};

sub col {
    shift->add_columns(shift ,=> shift);
}
sub primary_foreign {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $seen_table->{ $self } = $self;
    $args->{'is_foreign_key'} = 1;
    $self->add_columns($column_name => $args);
    $self->set_primary_key($self->primary_columns, $column_name);
    $self->handle_foreign_relations($column_name);
}

sub primary {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $seen_table->{ $self } = $self;
    my $has_many_sources = delete $args->{'_sweeten'}{'many'};
    my $many_to_many_sources = delete $args->{'_sweeten'}{'across'};

    $self->add_columns($column_name => $args);
    $self->set_primary_key($self->primary_columns, $column_name);

    return if !defined $has_many_sources && !defined $many_to_many_sources;

    if(defined $has_many_sources) {
        for my $other_result_source (keys %{ $has_many_sources }) {
            my $other_class = $self->result_source_to_class($other_result_source);
            my $relation_name = $self->result_source_to_relation_name($other_result_source, 1);
            my $reverse_relation_name = $self->result_source_to_relation_name($self, 0);

            $self->has_many($relation_name, $other_class, $column_name);
            $self->add_relation($other_class, 'belongs_to', $reverse_relation_name, $self, $column_name);
        }
    }
    if(defined $many_to_many_sources) {
        for my $across_source (keys %{ $many_to_many_sources}) {
            for my $to_source (keys %{ $many_to_many_sources->{ $across_source } }) {
                my $across_class = $self->result_source_to_class($across_source);
                my $across_relation_name = $self->result_source_to_relation_name($across_source, 1);
                my $across_reverse_relation_name = $self->result_source_to_relation_name($self, 0);

                my $to_relation_name = $self->result_source_to_relation_name($to_source, 1);
                my $to_primary_column = $self->result_source_to_relation_name($to_source, 0) . '_id';

                $self->has_many($across_relation_name, $across_class, $column_name);
                $self->many_to_many($to_relation_name, $across_relation_name, $to_primary_column);
                $self->add_relation($across_class, 'belongs_to', $across_reverse_relation_name, $self, $column_name);
            }
        }
    }
}
sub foreign {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $args->{'is_foreign_key'} = 1;
    $self->add_columns($column_name => $args);

    $self->handle_foreign_relations($column_name);

}
sub handle_foreign_relations {
    my $self = shift;
    my $column_name = shift;

    return if !exists $relations_to_add->{ $self }{ $column_name };
    my @relation = @{ delete $relations_to_add->{ $self }{ $column_name } };

    my $class = shift @relation;
    my $type = shift @relation;
    $class->$type(@relation);

    if(!keys %{ $relations_to_add->{ $self }}) {
        delete $relations_to_add->{ $self };
    }
}
sub unique {
    my $self = shift;
    my $column_name = shift;
    my $args = shift;

    $self->add_columns($column_name => $args);
    $self->add_unique_constraint([ $column_name ]);
}

sub result_source_to_relation_name {
    my $self = shift;
    my $result_source_name = shift;
    my $plural = shift || 0;
    my $resultclass = $self->clean_source_name($result_source_name);

    $resultclass =~ s{::}{_}g;
    $resultclass = String::CamelCase::decamelize($resultclass);

    return $resultclass.($plural ? 's' : '');
}
sub result_source_to_class {
    my $self = shift;
    my $other_result_source = shift;

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

sub add_relation {
    my $self = shift;
    my $class = shift;
    my $type = shift;
    my $relation_name = shift;
    my $other_class = shift;
    my $column_name = shift;

    if($seen_table->{ $class }) {
        $seen_table->{ $class }->$type($relation_name, $other_class, $column_name);
    }
    else {
        $relations_to_add->{ $class }{ $column_name } = [$class, $type, $relation_name, $other_class, $column_name];
    }
}

1;
