module std_ext.typetuple;

public import std.typetuple;
import std_ext.traits;

/** Construct a tuple of arrays of all the types in `T`, in order.
 *
 * Returns: A tuple of arrays of the types in `T`.
 */
template ArrayTuple(T...)
{
    static if(T.length == 0)
        alias TypeTuple!() ArrayTuple;
    else
        alias TypeTuple!(T[0][], ArrayTuple!(T[1..$])) ArrayTuple;
}

unittest
{
    struct Foo
    {
    }

    alias ArrayTuple!(int, Foo, char) Bar;

    static assert(Bar.length == 3);
    static assert(is(Bar[0] == int[]));
    static assert(is(Bar[1] == Foo[]));
    static assert(is(Bar[2] == char[]));

    static assert(ArrayTuple!().length == 0);
}

/** Determine whether or not `T` is an element of `U`.
 *
 * Returns: true iff `T` is found in `U`.
 */
template isElem(T, U...)
{
    enum isElem = (staticIndexOf!(T, U) >= 0);
}

unittest
{
    struct Foo
    {
    }

    static assert(isElem!(Foo, double, int, int, Foo));
    static assert(!isElem!(int, double, Foo, long, short));
}

/// Wraps `ArrayTuple!(T)` with some useful properties.
class TypeArray(T...)
{
    static if(NoDuplicates!(T).length !=  T.length)
        static assert(false, "Duplicate types in " ~ T.stringof);

    private ArrayTuple!(T) data;

    pure void add(U)(U obj) if(isElem!(U, T))
    {
        data[staticIndexOf!(U, T)] ~= obj;
    }

    // Iterate over all objects in `data`, calling `callback(data[i], args)` for each, starting with `i = n`.
    private void iterate(alias callback, uint n, U...)(U args)
    {
        static if(n < T.length)
        {
            foreach(ref x; data[n])
                if(callback(x, args))
                    return;

            iterate!(callback, n + 1)(args);
        }
    }

    // Iterate over all objects in `data`, calling `callback(data[i], args)` for each, starting with `i = n`.
    private const void constIterate(alias callback, uint n, U...)(U args)
    {
        static if(n < T.length)
        {
            foreach(x; data[n])
                if(callback(x, args))
                    return;

            constIterate!(callback, n + 1)(args);
        }
    }

    /** Iterate over each array, calling `callback(elem)`.
     *
     * Params:
     *      callback = The callback function to call, with each elem.
     *      args = Any additional arguments to pass to `callback`.
     *
     * Notes:
     *      If `callback` returns true, iteration is halted immediately.
     *      `elem` is passed by reference to `callback`.
     *      Each array is iterated over in the order expected.
     *      The arrays themselves are iterated over in the order of types in `_T`.
     */
    void templateForeach(alias callback, U...)(U args)
    {
        static assert(functionAlwaysInstantiable!(callback, T), "`callback` is not instantiable with all types in " ~ T.stringof ~ ".");
        static assert(alwaysReturns!(callback, bool, T), "`callback` must return a bool.");
        iterate!(callback, 0)(args);
    }

    /** Iterate over each array, calling `callback(elem)`.
     *
     * Params:
     *      callback = The callback function to call, with each elem.
     *      args = Any additional arguments to pass to `callback`.
     *
     * Notes:
     *      If `callback` returns true, iteration is halted immediately.
     *      Each array is iterated over in the order expected.
     *      The arrays themselves are iterated over in the order of types in `_T`.
     */
    const void templateForeach(alias callback, U...)(U args)
    {
        static assert(functionAlwaysInstantiable!(callback, T), "`callback` is not instantiable with all types in " ~ T.stringof ~ ".");
        static assert(alwaysReturns!(callback, bool, T), "`callback` must return a bool.");
        constIterate!(callback, 0)(args);
    }
}
