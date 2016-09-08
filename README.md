# NAME

DBIx::Class::Sweeten - Short intro

<div>
    <p>
    <img src="https://img.shields.io/badge/perl-5.16+-blue.svg" alt="Requires Perl 5.16+" />
    <a href="https://travis-ci.org//"><img src="https://api.travis-ci.org//.svg?branch=master" alt="Travis status" /></a>
    <a href="http://cpants.cpanauthors.org/release/CSSON/DBIx-Class-Sweeten-0.0102"><img src="http://badgedepot.code301.com/badge/kwalitee/CSSON/DBIx-Class-Sweeten/0.0102" alt="Distribution kwalitee" /></a>
    <a href="http://matrix.cpantesters.org/?dist=DBIx-Class-Sweeten%200.0102"><img src="http://badgedepot.code301.com/badge/cpantesters/DBIx-Class-Sweeten/0.0102" alt="CPAN Testers result" /></a>
    </p>
</div>

# VERSION

Version 0.0102, released 2016-09-08.

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

# AUTHOR

Erik Carlsson <info@code301.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Erik Carlsson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
