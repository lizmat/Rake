use v6.c;

role Rake:ver<0.0.2>:auth<cpan:ELIZABETH>[*@types] does Positional {
    has @!values handles <elems end gist iterator join Str>;
    has int $!end;

    method new(*@values) {
        @values
         ?? self.CREATE.STORE(@values, :INITIALIZE)
         !! self.CREATE
    }

    method STORE(*@values, :INITIALIZE($)!) {
        $!end = @types.end;

        X::OutOfRange.new(
          what  => 'number of values',
          got   => @values.elems,
          range => "{$!end + 1}..{$!end + 1}"
        ).throw if @values.end != $!end;

        for @values.kv -> $i, \value {
            X::TypeCheck.new(
              operation => "binding element #$i",
              expected  => @types[$i],
              got       => value.WHAT
            ).throw unless @types[$i].ACCEPTS(value);
            @values[$i] := value<>;  # decont
        }
        @!values := @values;

        self
    }

    method AT-POS(int $pos) {
        $pos < 0 || $pos > $!end
          ?? X::OutOfRange.new(
               what => 'index', got => $pos, range => "0..$!end"
             ).throw
          !! @!values.AT-POS($pos)
    }

    multi method raku(Rake:D:) {
        self.^name ~ '.new(' ~ @!values.raku.substr(1,*-1) ~ ')'
    }
}

=begin pod

=head1 NAME

Rake - raking typed values together in a list

=head1 SYNOPSIS

  use Rake;

  my $foo = Rake[Int,Str,IO].new(42,"bar","filename".IO);

  say $foo[0];  # 42
  say $foo[1];  # bar
  say $foo[2];  # "filename".IO

  .say for $foo;  # 42␤bar␤"filename".IO␤

  say $foo.^name;  # Rake[Int,Str,IO]

  my @bar := Rake[Int,Int].new(42,666);

  my @baz is Rake[Int,Int] = 42,666; # if Raku allows

=head1 DESCRIPTION

The Rake class (actually, a punned role) allows one to create an ad-hoc
collection of typed objects without the need to use a hash, list or class.
It only accepts values that smartmatch the given types on creation of the
collection and provides immutable positional values from the result.

It can be iterated over and be passed around as a single object.

=head1 INSPIRATION

Inspired by the remarks of C<bobthecimmerian> at:

  https://www.reddit.com/r/rakulang/comments/gfvb8w/raku_objects_confusing_or_what/fq16wjv/

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Rake . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
