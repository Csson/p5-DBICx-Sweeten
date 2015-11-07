# NAME

DBIx::Class::Sweeten - Short intro

![Requires Perl 5.16](https://img.shields.io/badge/perl-5.16-brightgreen.svg) [![Travis status](https://api.travis-ci.org//.svg?branch=master)](https://travis-ci.org//)

# VERSION

Version 0.0001, released 2015-11-07.

# SYNOPSIS

    # in MyApp::Schema, instead of inheriting from DBIx::Class::Schema
    use base 'DBIx::Class::Sweeten::Schema';

# DESCRIPTION

DBIx::Class::Sweeten is a collection of modules that can be used to reduce some boilerplate associated with [DBIx::Class](https://metacpan.org/pod/DBIx::Class).

- [DBIx::Class::Sweeten::Schema](https://metacpan.org/pod/DBIx::Class::Sweeten::Schema) - Access resultsets via method calls
- [DBIx::Class::Sweeten::Result::Base](https://metacpan.org/pod/DBIx::Class::Sweeten::Result::Base) - Adds a column attribute for easier indexing
- [DBIx::Class::Sweeten::Result](https://metacpan.org/pod/DBIx::Class::Sweeten::Result) - DBIx::Class::Candy defaults for result sources
- [DBIx::Class::Sweeten::ResultSet](https://metacpan.org/pod/DBIx::Class::Sweeten::ResultSet) - DBIx::Class::Candy defaults for resultsets

# SEE ALSO

- [DBIx::Class](https://metacpan.org/pod/DBIx::Class)
- [DBIx::Class::Candy](https://metacpan.org/pod/DBIx::Class::Candy) - Sugar for `DBIx::Class`
- [DBIx::Class::Helpers](https://metacpan.org/pod/DBIx::Class::Helpers) - More `DBIx::Class` goodness
- [DBICx::Shortcuts](https://metacpan.org/pod/DBICx::Shortcuts) - An alternative for `DBIx::Class::Sweeten::Schema`

# SOURCE

[https://github.com/Csson/p5-DBIx-Class-Sweeten](https://github.com/Csson/p5-DBIx-Class-Sweeten)

# HOMEPAGE

[https://metacpan.org/release/DBIx-Class-Sweeten](https://metacpan.org/release/DBIx-Class-Sweeten)

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
