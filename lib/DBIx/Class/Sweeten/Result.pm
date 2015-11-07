package DBIx::Class::Sweeten::Result {

    use base 'DBIx::Class::Candy';
    use String::CamelCase;

    sub base {
        (my $base = caller(2)) =~ s{::Schema::Result::.*$}{};

        return $_[1] || "${base}::Schema::Result";
    }
    sub autotable            { 1 }
    sub perl_version         { 20 }
    sub experimental {
        [qw/
            signatures
            postderef
        /];
    }

    sub gen_table {
        my $self = shift;
        my $resultclass = shift;

        $resultclass =~ s{^.*::Schema::Result::}{};
        $resultclass =~ s{::}{__}g;
        $resultclass = String::CamelCase::decamelize($resultclass);

        return $resultclass;
    }

}

1;
