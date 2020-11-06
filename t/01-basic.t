use v6.c;
use Test;
use Rake;

plan 11;

sub test-contents(
  \raked,
  $comments,
  $class = Rake[Int,Str].^pun,
  $raku  = 'Rake[Int,Str].new(42, "foo")'
) {  # is test-assertion
    sub sigtest(Rake[Int,Str] $raked) {
        pass 'is dispatch on signature ok';
    }

    subtest $comments => {
        ok raked.WHAT =:= $class<>, 'with the right type';
        is raked[0], 42,            'is the first value correct';
        is raked[1], 'foo',         'is the second value correct';
        is raked.Str, '42 foo',     'did it Str ok';
        is raked.gist, '[42 foo]',  'did it gist ok';
        is raked.raku, $raku,       'did it raku ok';
        is raked.elems, 2,          'is elems ok';
        is raked.end, 1,            'is end ok';

        sigtest(raked);
    }
}

{
    my $foo = Rake[Int,Str].new: 42,"foo";
    test-contents($foo, 'testing $foo assigned');
}

{
    my @foo := Rake[Int,Str].new: 42,"foo";
    test-contents(@foo, 'testing @foo bound');
}

{
    constant RIS = Rake[Int,Str]; # sadly need an intermediate constant for now
    my @bar is RIS = 42,"foo";
    test-contents(@bar, 'testing @bar with constant RIS');
}

{
    my class RIS does Rake[Int,Str] { }
    my @bar is RIS = 42,"foo";
    test-contents(
      @bar,
      'testing @bar with class RIS',
      RIS,
      'RIS.new(42, "foo")'
    );

    is (RIS.new(42,"foo"),RIS.new(42,"foo")).Set.elems, 1,
      'can we use identical Rake as value types';
}

if Compiler.new.version >= v2020.06 {
    test-contents(
      'my @bar is Rake[Int,Str] = 42,"foo"'.EVAL,
      'testing is Rake[Int,Str]'
    );
}
else {
    pass 'my @bar is Rake[Int,Str] syntax not yet supported';
}

{
    isa-ok Rake[Int,Str].new(42,"foo").WHICH, ValueObjAt,
      'do we get a value-type if all constituents are value-types';

    nok Rake[Int,Array].new(42,[666,]).WHICH ~~ ValueObjAt,
      'do we get a non value-type if any of constituents is not a value-type';
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

    dies-ok {
        Rake[Int,Array, :force-value-type].new(21, [])
    }, 'do we die when value-type is enforced, and non value-types given'
}

# vim: ft=perl6 expandtab sw=4
