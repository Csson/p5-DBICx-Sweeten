package DBIx::Class::Sweeten::Result {

    use base 'DBIx::Class::Core';

    sub sqlt_deploy_hook {
        my $self = shift;
        my $table = shift;

        my $complicated_indices = {};
        foreach my $column_name ($self->columns) {
            my $info = $self->column_info($column_name);

            if(exists $info->{'index'}) {
                if($info->{'index'} eq '1') {
                    my $index_name = sprintf 'idx_%s__%s', $table, $column_name;
                    $table->add_index(name => $index_name, fields => [$column_name]);
                }
                elsif(length $info->{'index'} > 1) {
                    my $index_name = sprintf 'idxm_%s__%s', $table, $info->{'index'};

                    if(!exists $complicated_indices->{ $index_name }) {
                        $complicated_indices->{ $index_name } = [];
                    }
                    push @{ $complicated_indices->{ $index_name } } => $column_name;
                }
            }
        }

        if(scalar keys %$complicated_indices) {
            foreach my $index_name (keys %$complicated_indices) {
                $table->add_index(name => $index_name, $complicated_indices->{ $index_name });
            }
        }
    }

}

1;
