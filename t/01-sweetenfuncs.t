use 5.10.0;
use strict;

use Test::More;

use if $ENV{'AUTHOR_TESTING'}, 'Test::Warnings';

use DBIx::Class::Sweeten -all;

my $tests = [
    {
        description => 'integer nullable',
        result => {
            data_type => 'integer',
            is_numeric => 1,
            is_nullable => 1,
        },
        test => integer nullable,
    },
    {
        description => 'mediumint 3',
        result => {
            data_type => 'mediumint',
            size => 3,
            is_numeric => 1,
        },
        test => mediumint 3,
    },
    {
        description => 'serial',
        result => {
            data_type => 'serial',
            is_numeric => 1,
        },
        test => serial,
    },
    {
        description => 'serial auto_increment',
        result => {
            data_type => 'serial',
            is_numeric => 1,
            is_auto_increment => 1,
        },
        test => serial auto_increment,
    },
    {
        description => 'varchar 150',
        result => {
            data_type => 'varchar',
            is_numeric => 0,
            size => 150,
        },
        test => varchar 150,
    },
    {
        description => 'nullable varchar 150, zerofill',
        result => {
            data_type => 'varchar',
            is_numeric => 0,
            size => 150,
            is_nullable => 1,
            extra => {
                zerofill => 1,
            },
        },
        test => nullable varchar 150, zerofill,
    },
    {
        description => 'varchar',
        result => {
            data_type => 'varchar',
            is_numeric => 0,
        },
        test => varchar,
    },
    {
        description => 'boolean',
        result => {
            data_type => 'boolean',
            is_numeric => 1,
        },
        test => boolean,
    },
    {
        description => 'bigint unsigned foreign_key',
        result => {
            data_type => 'bigint',
            is_numeric => 1,
            is_foreign_key => 1,
            extra => {
                unsigned => 1,
            },
        },
        test => bigint unsigned foreign_key,
    },
    {
        description => 'foreign_key unsigned bigint',
        result => {
            data_type => 'bigint',
            is_numeric => 1,
            is_foreign_key => 1,
            extra => {
                unsigned => 1,
            },
        },
        test => foreign_key unsigned bigint,
    },
    {
        description => 'bit',
        result => {
            data_type => 'bit',
            is_numeric => 1,
        },
        test => bit,
    },
    {
        description => 'tinyint',
        result => {
            data_type => 'tinyint',
            is_numeric => 1,
        },
        test => tinyint,
    },
    {
        description => 'smallint',
        result => {
            data_type => 'smallint',
            is_numeric => 1,
        },
        test => smallint,
    },

    {
        description => 'decimal',
        result => {
            data_type => 'decimal',
            is_numeric => 1,
        },
        test => decimal,
    },
    {
        description => 'decimal 3',
        result => {
            data_type => 'decimal',
            size => [3],
            is_numeric => 1,
        },
        test => decimal 3,
    },
    {
        description => 'decimal 3, unsigned',
        result => {
            data_type => 'decimal',
            is_numeric => 1,
            size => [3],
            extra => {
                unsigned => 1,
            }
        },
        test => decimal 3, unsigned,,
    },
    {
        description => 'decimal 4, 2',
        result => {
            data_type => 'decimal',
            size => [4, 2],
            is_numeric => 1,
        },
        test => decimal 4, 2,
    },
    {
        description => 'decimal 4, 2, unsigned auto_nextval',
        result => {
            data_type => 'decimal',
            size => [4, 2],
            is_numeric => 1,
            auto_nextval => 1,
            extra => {
                unsigned => 1,
            }
        },
        test => decimal 4, 2, unsigned auto_nextval,
    },
    {
        description => 'default_value 3.14, decimal 4, 2',
        result => {
            data_type => 'decimal',
            size => [4, 2],
            is_numeric => 1,
            default_value => 3.14,
        },
        test => default_value 3.14, decimal 4, 2,
    },
    {
        description => 'default_value 3.14, dec 4, 2',
        result => {
            data_type => 'decimal',
            size => [4, 2],
            is_numeric => 1,
            default_value => 3.14,
        },
        test => default_value 3.14, dec 4, 2,
    },
    {
        description => 'default_value 3.14, fixed 4, 2',
        result => {
            data_type => 'decimal',
            size => [4, 2],
            is_numeric => 1,
            default_value => 3.14,
        },
        test => default_value 3.14, fixed 4, 2,
    },
    {
        description => 'float',
        result => {
            data_type => 'float',
            is_numeric => 1,
        },
        test => float,
    },
    {
        description => 'float nullable',
        result => {
            data_type => 'float',
            is_numeric => 1,
            is_nullable => 1,
        },
        test => float nullable,
    },
    {
        description => 'double',
        result => {
            data_type => 'double',
            is_numeric => 1,
        },
        test => double,
    },
    {
        description => 'real',
        result => {
            data_type => 'double',
            is_numeric  => 1,
        },
        test => real,
    },
    {
        description => 'char',
        result => {
            data_type => 'char',
            is_numeric => 0,
        },
        test => char,
    },
    {
        description => 'varbinary',
        result => {
            data_type => 'varbinary',
            is_numeric => 0,
        },
        test => varbinary,
    },
    {
        description => 'binary',
        result => {
            data_type => 'binary',
            is_numeric => 0,
        },
        test => binary,
    },
    {
        description => 'tinytext',
        result => {
            data_type => 'tinytext',
            is_numeric => 0,
        },
        test => tinytext,
    },
    {
        description => 'text',
        result => {
            data_type => 'text',
            is_numeric => 0,
        },
        test => text,
    },
    {
        description => 'mediumtext',
        result => {
            data_type => 'mediumtext',
            is_numeric => 0,
        },
        test => mediumtext,
    },
    {
        description => 'longtext',
        result => {
            data_type => 'longtext',
            is_numeric => 0,
        },
        test => longtext,
    },
    {
        description => 'tinyblob',
        result => {
            data_type => 'tinyblob',
            is_numeric => 0,
        },
        test => tinyblob,
    },
    {
        description => 'blob',
        result => {
            data_type => 'blob',
            is_numeric => 0,
        },
        test => blob,
    },
    {
        description => 'mediumblob',
        result => {
            data_type => 'mediumblob',
            is_numeric => 0,
        },
        test => mediumblob,
    },
    {
        description => 'longblob',
        result => {
            data_type => 'longblob',
            is_numeric => 0,
        },
        test => longblob,
    },
    {
        description => 'enum [qw/here are values/]',
        result => {
            data_type => 'enum',
            is_numeric => 0,
            extra => {
                list => [qw/here are values/],
            },
        },
        test => enum [qw/here are values/],
    },
    {
        description => q{enum [qw/here are values/], default_value 'values'},
        result => {
            data_type => 'enum',
            is_numeric => 0,
            extra => {
                list => [qw/here are values/],
            },
            default_value => 'values',
        },
        test => enum [qw/here are values/], default_value 'values',
    },

    {
        description => q{integer unsigned extra whatever => 1},
        result => {
            data_type => 'integer',
            is_numeric => 1,
            extra => {
                unsigned => 1,
                whatever => 1,
            },
        },
        test => integer unsigned extra whatever => 1,
    },
    {
        description => q{type 'point', not_numeric attr stuff => 0},
        result => {
            data_type => 'point',
            is_numeric => 0,
            stuff => 0,
        },
        test => type 'point', attr stuff => 0, not_numeric,
    },
    {
        description => q{not_numeric type 'point'},
        result => {
            data_type => 'point',
            is_numeric => 0,
        },
        test => not_numeric type 'point',
    },
    {
        description => q{type point, not_numeric attr stuff => 0},
        result => {
            data_type => 'point',
            is_numeric => 0,
            stuff => 0,
        },
        test => type 'point', not_numeric attr stuff => 0,
    },
    {
        description => q{integer attr stuff => 0, accessor 'read_column', renamed_from 'former_name'},
        result => {
            data_type => 'integer',
            stuff => 0,
            is_numeric => 1,
            accessor => 'read_column',
            extra => {
                renamed_from => 'former_name',
            },
        },
        test => integer attr stuff => 0, accessor 'read_column', renamed_from 'former_name',
    },
    {
        description => q{integer extra stuff => 0, unsigned accessor 'read_column'},
        result => {
            data_type => 'integer',
            is_numeric => 1,
            accessor => 'read_column',
            extra => {
                unsigned => 1,
                stuff => 0,
            },
        },
        test => integer extra stuff => 0, unsigned accessor 'read_column',
    },
    {
        description => q{type 'strangeint', auto_increment numeric sequence 'strangeseq', retrieve_on_insert},
        result => {
            data_type => 'strangeint',
            is_numeric => 1,
            is_auto_increment => 1,
            sequence => 'strangeseq',
            retrieve_on_insert => 1,
        },
        test => type 'strangeint', auto_increment numeric sequence 'strangeseq', retrieve_on_insert,
    },
    {
        description => q{integer retrieve_on_insert numeric 1, sequence 'mysequence'},
        result => {
            data_type => 'integer',
            is_numeric => 1,
            retrieve_on_insert => 1,
            sequence => 'mysequence',
            default_value => \'NULL',
        },
        test => integer retrieve_on_insert default_value null, numeric 1, sequence 'mysequence',
    },
    {
        description => 'integer numeric',
        result => {
            data_type => 'integer',
            is_numeric => 1,
        },
        test => integer numeric,
    },
    {
        description => q{auto_nextval type 'custom'},
        result => {
            data_type => 'custom',
            auto_nextval => 1,
        },
        test => auto_nextval type 'custom',
    },
    {
        description => 'datetime',
        result => {
            data_type => 'datetime',
            is_numeric => 0,
        },
        test => datetime,
    },
    {
        description => 'datetime default now',
        result => {
            data_type => 'datetime',
            is_numeric => 0,
            default_value => \'NOW()',
        },
        test => datetime default_value now,
    },
    {
        description => 'default now, datetime',
        result => {
            data_type => 'datetime',
            is_numeric => 0,
            default_value => \'NOW()'
        },
        test => default_value now, datetime,
    },
    {
        description => 'date',
        result => {
            data_type => 'date',
            is_numeric => 0,
        },
        test => date,
    },
    {
        description => 'timestamp set_on_update set_on_create default_value current_timestamp',
        result => {
            data_type => 'timestamp',
            is_numeric => 0,
            set_on_update => 1,
            set_on_create => 1,
            default_value => \'CURRENT_TIMESTAMP'
        },
        test => timestamp set_on_update set_on_create default_value current_timestamp,
    },
    {
        description => 'time set_on_update',
        result => {
            data_type => 'time',
            is_numeric => 0,
            set_on_update => 1,
        },
        test => time set_on_update,
    },
    {
        description => 'year',
        result => {
            data_type => 'year',
            is_numeric => 0,
            set_on_create => 1,
        },
        test => year set_on_create,
    },
    {
        description => '',
        result => {
        },
        test => ,
    },
];

for my $test (@{ $tests }) {
    next if !length $test->{'test'};
    my $got = $test->{'test'};
    is_deeply $got, $test->{'result'}, $test->{'description'} or diag explain $got;
}

done_testing;
