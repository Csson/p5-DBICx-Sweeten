package DBIx::Class::Sweeten::ResultSet::Candy {

    use base 'DBIx::Class::Candy::ResultSet';

    sub base {
    	(my $base = caller(2)) =~ s{^(.*?)::Schema::ResultSet::.*}{$1};

        return $_[1] || "${base}::Schema::Result";
    }
    sub perl_version { 20 }

    sub experimental {
        [qw/
            signatures
            postderef
        /];
    }
}

1;
