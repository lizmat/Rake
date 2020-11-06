use v6.c;

role Rake:ver<0.0.3>:auth<cpan:ELIZABETH>[*@types, :$value-type]
  does Positional
{
    has ObjAt $.WHICH;
    has @!values handles <elems end gist iterator join Str>;

    my int $elems = @types.elems;  # reifies

    proto method new(|) {*}
    multi method new()         { self.CREATE                             }
    multi method new(*@values) { self.CREATE.STORE(@values, :INITIALIZE) }

    method STORE(*@values, :INITIALIZE($)!) is hidden-from-backtrace {

        # uh oh
        if @values.elems != $elems  { # reifies
            X::OutOfRange.new(
              what  => 'number of values',
              got   => @values.elems,
              range => "$elems..$elems"
            ).throw;
        }

        # wants a value type for set semantics
        elsif $value-type {
            my @which = self.^name;
            for @values.kv -> $i, \value {
                if @types[$i].ACCEPTS(value) {
                    my $WHICH := value.WHICH;
                    if $WHICH ~~ ValueObjAt {
                        @which.push($WHICH);
                        @!values[$i] := value<>;  # decont
                    }
                    else {
                        die "Received non value-type for element #$i when :force-value-type active";
                    }
                }
                else {
                    X::TypeCheck.new(
                      operation => "binding element #$i",
                      expected  => @types[$i],
                      got       => value.WHAT
                    ).throw;
                }
            }
            $!WHICH := ValueObjAt.new(@which.join('|'))
        }

        # not a value type
        else {
            for @values.kv -> $i, \value {
                @types[$i].ACCEPTS(value)
                  ?? (@!values[$i] := value<>)  # decont
                  !! X::TypeCheck.new(
                       operation => "binding element #$i",
                       expected  => @types[$i],
                       got       => value.WHAT
                     ).throw;
            }
            $!WHICH := self.Mu::WHICH;
        }

        self
    }

    method AT-POS(int $pos) is hidden-from-backtrace {
        0 <= $pos < $elems
          ?? @!values.AT-POS($pos)
          !! X::OutOfRange.new(
               what => 'index', got => $pos, range => "0..{$elems - 1}"
             ).throw
    }

    multi method raku(Rake:D: --> Str:D) {
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

=head1 DESCRIPTION

The Rake class (actually, a punned role) allows one to create an ad-hoc
collection of typed objects without the need to use a hash, list or class.
It only accepts values that smartmatch the given types on creation of the
collection and provides immutable positional values from the result.

It can be iterated over and be passed around as a single object.  It can
also be used as a constraint in dispatch.

Optionally, it can force objects of the Rake class to act like value types
so they can be used with C<Set> semantics: this can be achieved by specifying
the C<:value-type> named parameter with a C<True> value.

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
