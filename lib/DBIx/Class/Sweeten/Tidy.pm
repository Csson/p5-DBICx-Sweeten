use 5.20.0;
use strict;
use warnings;

package DBIx::Class::Sweeten::Tidy;

# ABSTRACT: Short intro
# AUTHORITY
our $VERSION = '0.0102';

use Carp qw/croak/;
use List::Util qw/uniq/;
use List::SomeUtils qw/any/;
use boolean;
use DBIx::Class::Sweeten::Q;
use Sub::Exporter::Progressive -setup => {
    exports => [qw/
        true
        false
        Relationship
        ForeignKey
        BitField
        TinyIntField
        SmallIntField
        MediumIntField
        IntegerField
        BigIntField
        SerialField
        BooleanField
        NumericField
        NonNumericField
        DecimalField
        FloatField
        DoubleField
        VarcharField
        CharField
        VarBinaryField
        BinaryField
        TinyTextField
        TextField
        MediumTextField
        LongTextField
        TinyBlobField
        BlobField
        MediumBlobField
        LongBlobField
        EnumField
        DateField
        DateTimeField
        TimestampField
        TimeField
        YearField
        Q
    /],
};

use experimental qw/postderef signatures/;

sub Q(@args) {
    return DBIx::Class::Sweeten::Q->new(value => \@args);
}

sub merge($first, $second) {
    my $merged = do_merge($first, $second);

    if(!exists $merged->{'extra'}) {
        $merged->{'extra'} = {};
    }
    $merged->{'_sweeten'} = {};

    for my $key (keys $merged->%*) {
        if($key =~ m{^-(.*)}) {
            my $clean_key = $1;
            $merged->{'extra'}{ $clean_key } = delete $merged->{ $key };
        }
        elsif($key eq 'many') {
            $merged->{'_sweeten'}{'has_many'} = delete $merged->{'many'} || [];
        }
        elsif($key eq 'might') {
            $merged->{'_sweeten'}{'might_have'} = delete $merged->{'might'} || [];
        }
        elsif($key eq 'one') {
            $merged->{'_sweeten'}{'has_one'} = delete $merged->{'one'} || [];
        }
        elsif($key eq 'across') {
            my $acrosses = delete $merged->{'across'};
            for (my $i = 0; $i < scalar $acrosses->@*; ++$i) {
                my $from = $acrosses->[$i];
                my $to = $acrosses->[$i + 1];
                $merged->{'_sweeten'}{'across'}{ $from }{ $to } = 1;
            }
        }
    }

    my %alias = (
        nullable => 'is_nullable',
        auto_increment => 'is_auto_increment',
        foreign_key => 'is_foreign_key',
        default => 'default_value',
    );

    for my $alias (keys %alias) {
        if(exists $merged->{ $alias }) {
            my $actual = $alias{ $alias };
            $merged->{ $actual } = delete $merged->{ $alias };
        }
    }
    return $merged;
}
sub do_merge($first, $second) {
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
                $merged->{ $key } = do_merge($first->{ $key }, $second->{ $key });
            }
        }
    }

    return $merged;
}

=pod
    custom settings:
    {
        indexed => [0, 1]               # if true -> auto indexed
        indexed => 'custom_name'        # can be used in multiple columns to create a composite index

        nullable => 1,                  # alias for 'is_nullable'
        auto_increment => 1,            # alias for 'is_auto_increment'
        foreign_key => 1,               # alias for 'is_foreign_key'
        default => '...',               # alias for 'default_value'
        -whatev                         # prefixed with '-' will be moved into 'extra' hash
    }
=cut
=pod
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

# sweeten extras
sub indexed {
    return merge { indexed => 1 }, shift || {};
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
=cut


sub Relationship($result_class, $relationship_name, $foreign_column) {
    return {
        type => 'relationship',
        result_class => $result_class,
        relationship_name => $relationship_name,
        foreign_column => $foreign_column,
    };
}

# this can only be used in the best case, where we can lift the definition from the primary key it points to
# and also does belongs_to<->has_many relationships
sub ForeignKey(%settings) {
    # 'sql' is the attr to the relationship
    # 'related_name' is the name of the inverse relationship, set to undef to skip creation
    # 'related_sql' is the attr to the inverse relationship
    my @approved_keys = qw/nullable indexed sql related_name related_sql/;
    my @keys_in_settings = keys %settings;

    KEY:
    for my $key (@keys_in_settings) {
        next KEY if any { $key eq $_ } @approved_keys;
        delete $settings{ $key };
    }

    return merge { _sweeten_foreign_key => 1 }, \%settings;
}

# data types - integers
sub _integer_type($type, $settings = {}) {
    return merge { data_type => $type, is_numeric => 1 }, $settings;
}

sub BitField(%settings) {
    return _integer_type(bit => \%settings);
}
sub TinyIntField(%settings) {
    return _integer_type(tinyint => \%settings);
}
sub SmallIntField(%settings) {
    return _integer_type(smallint => \%settings);
}
sub MediumIntField(%settings) {
    return _integer_type(mediumint => \%settings);
}
sub IntegerField(%settings) {
    return _integer_type(integer => \%settings);
}
sub BigIntField(%settings) {
    return _integer_type(bigint => \%settings);
}
sub SerialField(%settings) {
    return _integer_type(serial => \%settings);
}
sub BooleanField(%settings) {
    return _integer_type(boolean => \%settings);
}
# / integers

sub NumericField(%settings) {
    return merge { is_numeric => 1 }, \%settings;
}
sub NonNumericField(%settings) {
    return merge { is_numeric => 0 }, \%settings;
}


# data types - other numericals
sub DecimalField(%settings) {
    return merge { data_type => 'decimal', is_numeric => 1 }, \%settings;
}

sub _float_and_double($type, $settings = {}) {
    return merge { data_type => $type, is_numeric => 1 }, $settings;
}
sub FloatField(%settings)  {
    return _float_and_double(float => \%settings);
}
sub DoubleField(%settings) {
    return _float_and_double(double => \%settings);
}

# data types - strings
sub _charvar($type, $settings) {
    return merge { data_type => $type, is_numeric => 0 }, $settings;
}
sub VarcharField(%settings) {
    return _charvar(varchar => \%settings);
}
sub CharField(%settings) {
    return _charvar(char => \%settings);
}
sub VarBinaryField(%settings) {
    return _charvar(varbinary => \%settings);
}
sub BinaryField(%settings) {
    return _charvar(binary => \%settings);
}

sub _blobtext($text, $settings) {
    return merge { data_type => shift, is_numeric => 0 }, $settings;
}
sub TinyTextField(%settings) {
    return _blobtext(tinytext => \%settings);
}
sub TextField(%settings) {
    return _blobtext(text => \%settings);
}
sub MediumTextField(%settings) {
    return _blobtext(mediumtext => \%settings);
}
sub LongTextField(%settings) {
    return _blobtext(longtext => \%settings);
}
sub TinyBlobField(%settings) {
    return _blobtext(tinyblob => \%settings);
}
sub BlobField(%settings) {
    return _blobtext(blob => \%settings);
}
sub MediumBlobField(%settings) {
    return _blobtext(mediumblob => \%settings);
}
sub LongBlobField(%settings) {
    return _blobtext(longblob => \%settings);
}

sub EnumField(%settings) {
    if(exists $settings{'extra'} && exists $settings{'extra'}{'list'}) {
        # all good
    }
    elsif(exists $settings{'-list'}) {
        if(exists $settings{'extra'}) {
            $settings{'extra'}{'list'} = delete $settings{'list'};
        }
        else {
            $settings{'extra'} = { list => delete $settings{'list'} };
        }
    }
    else {
        croak qq{'enum' expects '-list => [qw/the possible values/]' or 'extra => { list => [qw/the possible values/] }'};
    }
    return merge { data_type => 'enum', is_numeric => 0 }, \%settings;
}

# data types - dates and times
sub _dates_and_times($type, $settings) {
    return merge { data_type => shift, is_numeric => 0 }, $settings;
}
sub DateField(%settings) {
    return _dates_and_times(date => \%settings);
}
sub DateTimeField(%settings) {
    return _dates_and_times(datetime => \%settings);
}
sub TimestampField(%settings) {
    return _dates_and_times(timestamp => \%settings);
}
sub TimeField(%settings) {
    return _dates_and_times(time => \%settings);
}
sub YearField(%settings) {
    return _dates_and_times(year => \%settings);
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
