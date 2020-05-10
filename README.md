NAME
====

Rake - raking typed values together in a list

SYNOPSIS
========

    use Rake;

    my $foo = Rake[Int,Str,IO].new(42,"bar","filename".IO);

    say $foo[0];  # 42
    say $foo[1];  # bar
    say $foo[2];  # "filename".IO

    .say for $foo;  # 42␤bar␤"filename".IO␤

    say $foo.^name;  # Rake[Int,Str,IO]

    my @bar := Rake[Int,Int].new(42,666);

    my @baz is Rake[Int,Int] = 42,666; # if Raku allows

DESCRIPTION
===========

The Rake class (actually, a punned role) allows one to create an ad-hoc collection of typed objects without the need to use a hash, list or class. It only accepts values that smartmatch the given types on creation of the collection and provides immutable positional values from the result.

It can be iterated over and be passed around as a single object.

INSPIRATION
===========

Inspired by the remarks of `bobthecimmerian` at:

    https://www.reddit.com/r/rakulang/comments/gfvb8w/raku_objects_confusing_or_what/fq16wjv/

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Rake . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

