module std_ext.traits;

public import std.traits;
import std.typetuple;

/// Returns true iff `callback` returns something of type T, with any template parameter in U.
template alwaysReturns(alias callback, T, U...)
{
    static if(U.length == 0)
        enum alwaysReturns = true;
    else static if(!is(ReturnType!(callback!(U[0])) == T))
        enum alwaysReturns = false;
    else
        enum alwaysReturns = alwaysReturns!(callback, T, U[1..$]);
}

unittest
{
    struct Foo
    {
    }

    int bar(T)()
    {
        return 0;
    }

    Foo foobar(T)()
    {
        return Foo();
    }

    T fizz(T)()
    {
        return T.init;
    }

    assert(alwaysReturns!(bar, int, int, double, Foo));
    assert(alwaysReturns!(foobar, Foo, int, double, Foo));

    assert(!alwaysReturns!(bar, long, int, double, Foo));
    assert(!alwaysReturns!(bar, Foo, int, double, Foo));
    assert(!alwaysReturns!(foobar, void, int, double, Foo));
    assert(!alwaysReturns!(fizz, int, int, double, Foo));
    assert(!alwaysReturns!(fizz, double, int, double, Foo));
    assert(!alwaysReturns!(fizz, Foo, int, double, Foo));
}

/// Returns true iff `callback` returns something implicitly castable to type T, with any template parameter in U.
template alwaysReturnsCastable(alias callback, T, U...)
{
    static if(U.length == 0)
        enum alwaysReturnsCastable = true;
    else static if(!is(ReturnType!(callback!(U[0])) : T))
        enum alwaysReturnsCastable = false;
    else
        enum alwaysReturnsCastable = alwaysReturnsCastable!(callback, T, U[1..$]);
}

unittest
{
    struct Foo
    {
    }

    int bar(T)()
    {
        return 0;
    }

    Foo foobar(T)()
    {
        return Foo();
    }

    T fizz(T)()
    {
        return T.init;
    }

    assert(alwaysReturnsCastable!(bar, int, int, double, Foo));
    assert(alwaysReturnsCastable!(foobar, Foo, int, double, Foo));
    assert(alwaysReturnsCastable!(bar, long, int, double, Foo));

    assert(!alwaysReturnsCastable!(bar, Foo, int, double, Foo));
    assert(!alwaysReturnsCastable!(foobar, void, int, double, Foo));
    assert(!alwaysReturnsCastable!(fizz, int, int, double, Foo));
    assert(!alwaysReturnsCastable!(fizz, double, int, double, Foo));
    assert(!alwaysReturnsCastable!(fizz, Foo, int, double, Foo));
}

/// Returns true iff `f` is instantiable with all types in `T`.
template functionAlwaysInstantiable(alias f, T...)
{
    static if(T.length == 0)
        enum functionAlwaysInstantiable = true;
    else static if(!is(typeof(f!(T[0]))))
        enum functionAlwaysInstantiable = false;
    else
        enum functionAlwaysInstantiable = functionAlwaysInstantiable!(f, T[1..$]);
}

unittest
{
    struct Foo
    {
    }

    void bar(T)()
    {
    }

    void foobar(T)() if(is(T == int) || is(T == Foo))
    {
    }

    assert(functionAlwaysInstantiable!(bar, int, double, Foo));
    assert(functionAlwaysInstantiable!(foobar, int, Foo));

    assert(!functionAlwaysInstantiable!(foobar, int, double, Foo));
}
