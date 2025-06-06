[![Actions Status](https://github.com/lizmat/Rake/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Rake/actions) [![Actions Status](https://github.com/lizmat/Rake/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Rake/actions) [![Actions Status](https://github.com/lizmat/Rake/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Rake/actions)

NAME
====

Rake - raking typed values together in a list

SYNOPSIS
========

```raku
use Rake;

my $foo = Rake[Int,Str,IO].new(42,"bar","filename".IO);
say $foo[0];  # id: 42
say $foo[1];  # name: bar
say $foo[2];  # path: "filename".IO

.say for $foo;  # 42␤bar␤"filename".IO␤

say $foo.^name;  # Rake[Int,Str,IO]

my @bar := Rake[Int,Int].new(42,666);

constant RIS = Rake[Int,Str];        # Rakudo < v2020.06
my @baz is RIS = 42,"foo";

my @baz is Rake[Int,Str] = 42,"foo"; # Rakudo >= v2020.06

class CIS does Rake[Int,Str] { }
my @caz is CIS = 42,"foo";

sub take-rake(Rake[Int,Str] $raked) {
  say "got: $raked";
}

sub answers(*@answers) {
  Rake[Int xx @answers, :value-type].new(@answers)
}
say (answers(42,666), answers(42,666)).Set.elems;  #1
```

DESCRIPTION
===========

The `Rake` class (actually, a punned role) allows one to create an ad-hoc collection of typed objects without the need to use a hash, list or class. It only accepts values that smartmatch the given types on creation of the collection and provides immutable positional values from the result.

It can be iterated over and be passed around as a single object. It can also be used as a constraint in dispatch.

Optionally, it can force objects of the Rake class to act like value types so they can be used with `Set` semantics: this can be achieved by specifying the `:value-type` named argument with a `True` value.

WHEN NOT TO USE THIS FUNCTIONALITY
==================================

This functionality is really intended for **ad-hoc** data structures, as a way to easily prototype or enforce type-checking on some trial code. For production, it is recommended to change each of the `Rake` cases into an actual class with typed attributes: this will help in performance **and** future maintainability.

Taking from the example code:

```raku
my $foo = Rake[Int,Str,IO].new(42,"bar","filename".IO);
say $foo[0];  # id: 42
say $foo[1];  # name: bar
say $foo[2];  # path: "filename".IO
```

for production could be written as:

```raku
class Foo {
  has Int      $.id;
  has Str      $.name;
  has IO::Path $.path;
}

my $foo = Foo.new(:id(42), :name<bar>, :path("filename".IO));
say $foo.id;    # 42
say $foo.name;  # bar
say $foo.path;  # "filename".IO
```

You will thank yourself in the future!

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Rake . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2020, 2021, 2024, 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

