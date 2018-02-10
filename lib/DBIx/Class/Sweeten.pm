use 5.10.0;
use strict;
use warnings;

package DBIx::Class::Sweeten;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0103';

use Carp qw/croak/;
use List::Util qw/uniq/;
use Sub::Exporter::Progressive -setup => {
    exports => [qw/
        type
        numeric
        not_numeric
        accessor
        nullable
        auto_increment
        foreign_key
        sequence
        retrieve_on_insert
        auto_nextval
        attr
        extra
        default_value
        unsigned
        binary_flag
        varchar
        char
        varbinary
        binary
        tinytext
        text
        mediumtext
        longtext
        tinyblob
        blob
        mediumblob
        longblob
        enum
        zerofill
        renamed_from
        indexed
        bit
        tinyint
        smallint
        mediumint
        integer
        bigint
        serial
        bool
        boolean
        decimal
        dec
        numeric
        fixed
        float
        double
        real
        date
        datetime
        timestamp
        time
        year
        set_on_create
        set_on_update
        now
        current_timestamp
        null

        many
        across
        might
        one
    /],
    groups => {
        default => [qw/
            nullable
            auto_increment
            foreign_key
            attr
            extra
            default_value
            bit
            tinyint
            smallint
            mediumint
            integer
            bigint
            serial
            boolean
            decimal
            fixed
            float
            double
            varchar
            char
            varbinary
            binary
            tinytext
            text
            mediumtext
            longtext
            tinyblob
            blob
            mediumblob
            longblob
            date
            datetime
            timestamp
            time
            year
        /],
        mysql => [qw/
            unsigned
            binary_flag
            zerofill
            renamed_from
        /],
        timestamp => [qw/
            set_on_create
            set_on_update
        /],
        values => [qw/
            now
            current_timestamp
            null
        /],
    },
};

sub merge {
    my $first = shift;
    my $second = shift;

    my $merged = {};
    for my $key (uniq (keys %{ $first }, keys %{ $second })) {
        if(exists $first->{ $key } && !exists $second->{ $key }) {
            $merged->{ $key } = $first->{ $key };
        }
        elsif(!exists $first->{ $key } && exists $second->{ $key }) {
            $merged->{ $key } = $second->{ $key };
        }
        else {
            if(ref $first->{ $key } ne 'HASH' && $second->{ $key } ne 'HASH') {
                $merged->{ $key } = $first->{ $key };
            }
            else {
                $merged->{ $key } = merge($first->{ $key }, $second->{ $key });
            }
        }
    }

    return $merged;
}
sub many {
    return merge { _sweeten => { has_many => { shift ,=> 1 } } }, shift || {};
}
sub across {
    return merge { _sweeten => { across => { shift ,=> { shift ,=> 1 } } } }, shift || {};
}
sub might {
    return merge { _sweeten => { might_have => { shift ,=> 1 } } }, shift || {};
}
sub one {
    return merge { _sweeten => { has_one => { shift ,=> 1 } } }, shift || {};
}

sub type {
    return merge { data_type => shift }, shift || {};
}
sub numeric {
    my $is_numeric = defined $_[0] && ref $_[0] eq '' ? shift : 1;
    return merge { is_numeric => $is_numeric }, shift || {};
}
sub not_numeric {
    return merge { is_numeric => 0 }, shift || {};
}
sub accessor {
    return merge { accessor => shift }, shift || {};
}
sub nullable {
    return merge { is_nullable => 1 }, shift || {};
}
sub auto_increment {
    return merge { is_auto_increment => 1 }, shift || {};
}
sub foreign_key {
    return merge { is_foreign_key => 1 }, shift || {};
}
sub sequence {
    return merge { sequence => shift }, shift || {};
}
sub retrieve_on_insert {
    return merge { retrieve_on_insert => 1 }, shift || {};
}
sub auto_nextval {
    return merge { auto_nextval => 1 }, shift || {};
}
sub attr {
    return merge { shift ,=> shift }, shift || {};
}
sub extra {
    return merge { extra => { shift ,=> shift } }, shift || {};
}
sub default_value {
    if(ref $_[0] ne '' && ref $_[0] ne 'SCALAR') {
        croak sprintf q{'default' expects either a string or a scalar reference, you supplied a %s}, ref $_[0];
    }
    return merge { default_value => shift }, shift || {};
}

# mysql extras
sub unsigned {
    return merge { extra => { unsigned => 1 } }, shift || {};
}
sub binary_flag {
    return merge { extra => { binary => 1 } }, shift || {};
}
sub zerofill {
    return merge { extra => { zerofill => 1 } }, shift || {};
}
sub renamed_from {
    return merge { extra => { renamed_from => shift } }, shift || {};
}

# sweeten extras
sub indexed {
    return merge { indexed => 1 }, shift || {};
}


# data types - integers
sub integer_type {
    my $type = shift;
    my $size = defined $_[0] && ref $_[0] eq '' ? { size => shift } : {};
    return merge { data_type => $type, is_numeric => 1, %{ $size } }, shift || {};
}
sub bit {
    return integer_type(bit => shift, @_);
}
sub tinyint {
    return integer_type(tinyint => shift, @_);
}
sub smallint {
    return integer_type(smallint => shift, @_);
}
sub mediumint {
    return integer_type(mediumint => shift, @_);
}
sub integer {
    return integer_type(integer => shift, @_);
}
sub bigint {
    return integer_type(bigint => shift, @_);
}
sub serial {
    return merge { data_type => 'serial', is_numeric => 1 }, shift || {};
}

sub bool {
    return integer_type('boolean', @_)
}
sub boolean {
    return bool(@_);
}

# data types - other numericals
sub decimal {
    my $sizes = [];
    push @{ $sizes } => defined $_[0] && ref $_[0] eq '' ? shift : ();
    push @{ $sizes } => defined $_[0] && ref $_[0] eq '' ? shift : ();

    my $size = scalar @{ $sizes } ? { size => $sizes } : {};
    return merge { data_type => 'decimal', is_numeric => 1, %{ $size } }, shift || {};
}
sub dec     { return decimal(@_) };
sub fixed   { return decimal(@_) };

sub _float_and_double {
    my $type = shift;

    my $sizes = {};
    if(defined $_[0] && ref $_[0] eq '') {
        if(ref $_[1] ne '') {
            croak qq{'$type' expects either both M and D or neither, you only submitted one - can't use};
        }
        $sizes = { sizes => [splice @_, 0, 2] };
    }
    return merge { data_type => $type, is_numeric => 1, %{ $sizes } }, shift || {};
}
sub float  { return _float_and_double('float',  @_); }
sub double { return _float_and_double('double', @_); }
sub real   { return _float_and_double('double', @_); }

# data types - strings
sub _charvar {
    my $type = shift;
    my $size = defined $_[0] && ref $_[0] eq '' ? { size => shift } : {};

    return merge { data_type => $type, is_numeric => 0, %{ $size } }, shift || {};
}
sub varchar {
    return _charvar('varchar', @_);
}
sub char {
    return _charvar('char', @_);
}
sub varbinary {
    return _charvar('varbinary', @_);
}
sub binary {
    return _charvar('binary', @_);
}

sub _blobtext {
    return merge { data_type => shift, is_numeric => 0 }, shift || {};
}
sub tinytext {
    return _blobtext('tinytext', @_);
}
sub text {
    return _blobtext('text', @_);
}
sub mediumtext {
    return _blobtext('mediumtext', @_);
}
sub longtext {
    return _blobtext('longtext', @_);
}
sub tinyblob {
    return _blobtext('tinyblob', @_);
}
sub blob {
    return _blobtext('blob', @_);
}
sub mediumblob {
    return _blobtext('mediumblob', @_);
}
sub longblob {
    return _blobtext('longblob', @_);
}

sub enum {
    if(ref $_[0] ne 'ARRAY') {
        croak qq{'enum' expects an array reference as the first argument: 'enum [qw/the possible values/]'};
    }
    my $list = shift;
    return merge { data_type => 'enum', is_numeric => 0, extra => { list => $list } }, shift || {};
}

# data types - dates and times
sub dates_and_times {
    return merge { data_type => shift, is_numeric => 0 }, shift || {};
}
sub date { return dates_and_times('date', @_) }
sub datetime { return dates_and_times('datetime', @_) }
sub timestamp { return dates_and_times('timestamp', @_) }
sub time { return dates_and_times('time', @_) }
sub year { return dates_and_times('year', @_) }

sub set_on_create {
    return merge { set_on_create => 1 }, shift || {};
}
sub set_on_update {
    return merge { set_on_update => 1 }, shift || {};
}
sub now {
    return \'NOW()';
}
sub current_timestamp {
    return \'CURRENT_TIMESTAMP';
}
sub null {
    return \'NULL';
}

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
