package DBIx::Class::Sweeten::ResultSet {

    use base 'DBIx::Class::Candy::ResultSet';

    sub base {
    	(my $base = caller(2)) =~ s{^(.*?)::Schema::ResultSet::.*}{$1};

        return $_[1] || "${base}::Schema::ResultSet";
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
