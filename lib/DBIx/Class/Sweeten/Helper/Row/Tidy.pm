use 5.20.1;
use strict;
use warnings;

package DBIx::Class::Sweeten::Helper::Row::Tidy;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0102';

use parent 'DBIx::Class::Row';
use String::CamelCase;
use Module::Loader;
use Syntax::Keyword::Try;
use Carp qw/croak/;
use DBIx::Class::Candy::Exports;

use experimental qw/postderef signatures/;

export_methods [qw/
    col
    primary
    foreign
    belongs
    unique
    primary_belongs
/];

state $module_loader = Module::Loader->new;

sub col($self, $name, $definition) {
    $self->add_columns($name => $definition);
}

sub primary($self, $name, $definition) {

    my $normal = {
        #has_many => $definition->{'_sweeten'}{'has_many'}, # has_many is done from the belongs class
        might_have => $definition->{'_sweeten'}{'might_have'},
        has_one => $definition->{'_sweeten'}{'has_one'},
    };
    my $many_to_many_sources = delete $definition->{'_sweeten'}{'across'};
    delete $definition->{'_sweeten'};
    $self->add_columns($name => $definition);
    $self->set_primary_key($self->primary_columns, $name);

    for my $type (keys %{ $normal }) {
        for my $other_result_source (@{ $normal->{ $type }}) {
            croak ("TODO: fix might_have/has_one");

            # All of this was only tested on has_many, which no longer uses this code.

            if(!ref $other_result_source) {
                my $other_class = $self->result_source_to_class($other_result_source);
                my $relation_name = $self->result_source_to_relation_name($other_result_source, 1);
                my $foreign_column = $self->result_source_to_relation_name($self, 0) . '_id';
                my $inverted_relation_name = $self->result_source_to_relation_name($self, 0);
                $self->$type($relation_name, $other_class, { "foreign.$foreign_column" => "self.id" });
            }
            elsif(ref $other_result_source eq 'HASH') {
                # my $assisting_takeover = InvertedRelationship('Takeover', 'assisting_takeovers, 'assisted_takeover_id');
                # has_many assisting_takeovers => 'Turf::Schema::Result::Takeover' => { 'foreign.assisted_takeover_id' => 'self.id' };
                my $ors = $other_result_source;
                if($ors->{'type'} eq 'relationship') {
                    my $other_class = $ors->{'result_class'};
                    my $foreign_column = $ors->{'foreign_column'};
                    my $relationship = $ors->{'relationship_name'};

                    $self->$type($relationship, $other_class, { "foreign.$foreign_column" => "self.id" });
                }
            }
        }
    }
    if(defined $many_to_many_sources) {
        croak "many_to_many needs new development";
        for my $across_source (keys %{ $many_to_many_sources}) {
            for my $to_source (keys %{ $many_to_many_sources->{ $across_source } }) {
                my $across_class = $self->result_source_to_class($across_source);
                my $across_relation_name = $self->result_source_to_relation_name($across_source, 1);

                my $to_relation_name = $self->result_source_to_relation_name($to_source, 1);
                my $to_primary_column = $self->result_source_to_relation_name($to_source, 0) . '_id';

                $self->has_many($across_relation_name, $across_class, $name);
                $self->many_to_many($to_relation_name, $across_relation_name, $to_primary_column);
            }
        }
    }
}
sub primary_belongs($self, @remaining) {
    my $column_name = $self->belongs(@remaining);
    $self->set_primary_key($self->primary_columns, $column_name);

}
sub foreign($self, $column_name, $definition) {
    $definition->{'is_foreign_key'} = 1;
    $self->add_column($column_name => $definition);
}

# assumes that the primary key is called 'id'
sub belongs($self, $other_source, $relation_name_or_definition, $definition_or_undef = {}) {
    my $belongs_to_class = $self->result_source_to_class($other_source);
    my $relation_name = $self->result_source_to_relation_name($other_source);
    my $definition = {};

    # two-param call
    if(ref $relation_name_or_definition eq 'HASH') {
        $definition = $relation_name_or_definition;
    }
    # three-param call
    elsif(ref $definition_or_undef eq 'HASH') {
        $definition = $definition_or_undef;
        $relation_name = $relation_name_or_definition;
    }
    else {
        croak "Bad call to belongs in $self: 'belongs $other_source ...'";
    }
    my $column_name = $relation_name . '_id';


    # Its a ForeignKey field!
    if(exists $definition->{'_sweeten_foreign_key'}) {
        delete $definition->{'_sweeten_foreign_key'};
        $module_loader->load($belongs_to_class);

        my $primary_key_col = undef;

        try {
            $primary_key_col = $belongs_to_class->column_info('id');
        }
        catch {
            croak "$belongs_to_class has no column 'id'";
        }
        $definition->{'data_type'} = $primary_key_col->{'data_type'};
        $definition->{'is_foreign_key'} = 1;

        for my $attr (qw/size is_numeric/) {
            if(exists $primary_key_col->{ $attr }) {
                $definition->{ $attr } = $primary_key_col->{ $attr };
            }
        }
    }

    if(!exists $definition->{'data_type'}) {
        croak qq{ResultSource '$self' column '$column_name' => definition is missing 'data_type'};
    }
    my $sql = exists $definition->{'sql'} ? delete $definition->{'sql'} : {};
    my $related_name = exists $definition->{'related_name'} ? delete $definition->{'related_name'}
                     :                                        $self->result_source_to_relation_name($self, 1)
                     ;
    my $related_sql = exists $definition->{'related_sql'} ? delete $definition->{'related_sql'} : {};

    $self->foreign($column_name => $definition);
    $self->belongs_to($relation_name, $belongs_to_class, { "foreign.id" => "self.$column_name" }, $sql);

    if(defined $related_name) {
        $module_loader->load($belongs_to_class);
        $belongs_to_class->has_many($related_name, $self, { "foreign.$column_name" => "self.id" }, $related_sql);
    }

    return $column_name;

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
    return substr($other_result_source, 1) if substr($other_result_source, 0, 1) eq '^';
    return $self->base_namespace($self).$self->clean_source_name($other_result_source);
}
sub base_namespace {
    my $self = shift;
    my $class = shift;
    $class =~ m{^(.*?::Result::)};
    return $1;
}
sub clean_source_name {
    my $self = shift;
    my $source_name = shift;
    $source_name =~ s{^.*?::Result::}{};

    return $source_name;
}

1;
