use 5.20.0;
use strict;
use warnings;

package DBIx::Class::Sweeten::Result::Candy {

    use base 'DBIx::Class::Candy';
    use String::CamelCase;
    use experimental 'signatures';

    sub base($self, $custom) { $custom || 'PhotoTurf::Schema::Result' }
    sub autotable            { 1 }
    sub perl_version         { 20 }
    sub experimental {
        [qw/
            signatures
            postderef
        /];
    }

    sub gen_table($self, $resultclass, @other) {
        $resultclass =~ s{^.*::Schema::Result::}{};
        $resultclass =~ s{::}{__}g;
        $resultclass = String::CamelCase::decamelize($resultclass);

        return $resultclass;
    }

}

1;
