use v6.c;
use Test;
use Rake;

plan 26;

{
    my $foo = Rake[Int,Str].new: 42,"foo";

    ok $foo.WHAT =:= Rake[Int,Str].^pun, '$foo with the right type';
    is $foo[0], 42, '$foo is the first value correct';
    is $foo[1], 'foo', '$foo is the second value correct';
    is $foo.Str, '42 foo', '$foo did it Str ok';
    is $foo.gist, '[42 foo]', '$foo did it gist ok';
    is $foo.raku, 'Rake[Int,Str].new(42, "foo")', '$foo did it raku ok';
    is $foo.elems, 2, '$foo is elems ok';
    is $foo.end, 1, '$foo is end ok';
}

{
    my @foo := Rake[Int,Str].new: 42,"foo";

    ok @foo.WHAT =:= Rake[Int,Str].^pun, '@foo with the right type';
    is @foo[0], 42, '@foo is the first value correct';
    is @foo[1], 'foo', '@foo is the second value correct';
    is @foo.Str, '42 foo', '@foo did it Str ok';
    is @foo.gist, '[42 foo]', '@foo did it gist ok';
    is @foo.raku, 'Rake[Int,Str].new(42, "foo")', '@foo did it raku ok';
    is @foo.elems, 2, '@foo is elems ok';
    is @foo.end, 1, '@foo is end ok';
}

{
    constant RIS = Rake[Int,Str];  # sadly need an intermediate constant for now
    my @bar is RIS = 42,"foo";

    ok @bar.WHAT =:= Rake[Int,Str].^pun, '@bar with the right type';
    is @bar[0], 42, '@bar is the first value correct';
    is @bar[1], 'foo', '@bar is the second value correct';
    is @bar.Str, '42 foo', '@bar did it Str ok';
    is @bar.gist, '[42 foo]', '@bar did it gist ok';
    is @bar.raku, 'Rake[Int,Str].new(42, "foo")', '@bar did it raku ok';
    is @bar.elems, 2, '@bar is elems ok';
    is @bar.end, 1, '@bar is end ok';
}

{
    throws-like { Rake[Int,Str].new: 42,666 }, X::TypeCheck,
      expected => Str,
      got      => Int,
      'did we typecheck ok';

    throws-like { Rake[Int,Str].new: 42 }, X::OutOfRange,
      range => "2..2",
      got   => 1,
      'did we check number of values ok';
}
