use v6.d;

role Rake:ver<0.0.6>:auth<zef:lizmat>[*@types, :$value-type]
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
                      operation => "binding value-type element #$i",
                      expected  => @types[$i],  # UNCOVERABLE
                      got       => value.WHAT
                    ).throw;
                }
            }
            $!WHICH := ValueObjAt.new(@which.join('|'))
        }

        # don't require a value type
        else {
            for @values.kv -> $i, \value {
                @types[$i].ACCEPTS(value)
                  ?? (@!values[$i] := value<>)  # decont  # UNCOVERABLE
                  !! X::TypeCheck.new(
                       operation => "binding element #$i",
                       expected  => @types[$i],  # UNCOVERABLE
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

# vim: expandtab shiftwidth=4
