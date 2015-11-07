package DBIx::Class::Sweeten::Result::Base {

    use base 'DBIx::Class::Core';

    sub sqlt_deploy_hook {
        my $self = shift;
        my $table = shift;

        my $indices = {};
        for my $column_name ($self->columns) {
            my $info = $self->column_info($column_name);

            if($info->{'index'}) {
                
                my $indexvalues = ref $info->{'index'} ne 'ARRAY' ? [ $info->{'index'} ] : $info->{'index'};

                for my $indexvalue (@$indexvalues) {

                    if(length $indexvalue > 1) {
                        my $index_name = sprintf '%s_idxm_%s', $table, $indexvalue;

                        if(!exists $indices->{ $index_name }) {
                            $indices->{ $index_name } = [];
                        }
                        push @{ $indices->{ $index_name } } => $column_name;
                    }
                    else {
                        my $index_name = sprintf '%s_idxa_%s', $table, $column_name;
                        $indices->{ $index_name } = [$column_name];
                    }
                }
            }
        }

        if(scalar keys %$indices) {
            for my $index_name (keys %$indices) {
                $table->add_index(name => $index_name, fields => $indices->{ $index_name });
            }
        }
    }

}

1;

__END__

=pod

=head1 SYNOPSIS

    # in MyApp::Schema::Result::YourResultClass, instead of inheriting from DBIx::Class::Core
    use base 'DBIx::Class::Sweeten::Result::Base';

    # DBIx::Class::Candy is always nice
    use DBIx::Class::Candy;

    column last_name => {
        data_type => 'varchar',
        size => 150,
        index => 1,
    };

=head1 DESCRIPTION

Adding indices (apart from primary keys and unique constraints) requires creating a C<sqlt_deploy_hook> method and calling C<add_index> manually. This module
introduces the new C<index> column attribute.

=head2 Possible values

C<index> behaves differently depending on the value it is given:

=for :list
* If given a one-character value an index is created named C<[table_name]_idxa_[column_name]>.
* If given a more-than-one-character value an index is created name C<[table_name]_idxm_[index_name]>. If multiple columns are given the same name a composite index is created.
* If given an array reference each value in it is treated according to the two rules above. 

With these column definitions:

    table('Author');
    column first_name => {
        data_type => 'varchar',
        size => 150,
        index => 'name',
    };
    column last_name => {
        data_type => 'varchar',
        size => 150,
        index => [1, 'name'],
    };
    column country => {
        data_type => 'varchar',
        size => 150,
        index => 1,
    };

The following indices are created:

=for :list
* C<Author_idxm_name> consisting of C<first_name> and C<last_name>
* C<Author_idxa_last_name> consisting of C<last_name>
* C<Author_idxa_country> consisting of C<country>

=head2 Needs a custom sqlt_deploy_hook?

If you still need an C<sqlt_deploy_hook> method in a result source just call the parent's C<sqlt_deploy_hook> first:

    sub sqlt_deploy_hook {
        my $self = shift;
        my $table = shift;

        $self->next::method($table);

        ...
    }

=cut
