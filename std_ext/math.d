module std_ext.math;

public import std.math;
import std.algorithm;

/// Get the square root of `n` as an integer.
pure T sqrt(T)(T n) if(is(T : ulong) || is(T : real))
{
    return cast(T)sqrt(cast(real)n);
}

unittest
{
    pure bool sqrtMatchesTo(ulong n)
    {
        for(ulong i = 0; i <= n; ++i)
            if(cast(ulong)sqrt(cast(real)n) != sqrt(n))
                return false;

        return true;
    }

    assert(sqrtMatchesTo(1024));
}

private pure ulong[] getPrimesUpTo(ulong n, ulong[] primesCache)
{
    if(n < 2)
        return [];

    assert(primesCache.length > 0);

    for(ulong i = primesCache[$ - 1]; i <= n; ++i)
        if(isPrime(i, primesCache))
            primesCache ~= i;

    return primesCache;
}

// TODO: Overflow checking with loops.
private pure ulong[] getPrimes(ulong n, ulong[] primesCache)
{
    if(n == 0)
        return [];

    assert(primesCache.length > 0);

    auto last = primesCache[$ - 1];

    for(auto i = primesCache.length; i < n; ++i)
    {
        do ++last;
        while(!isPrime(last, primesCache));

        primesCache ~= last;
    }

    return primesCache;
}

private pure bool isPrime(ulong n, ulong[] primesCache)
{
    if(n < 2)
        return false;

    auto s = sqrt(n);
    getPrimesUpTo(s, primesCache);

    foreach(prime; primesCache)
    {
        if(prime > s)
            return true;

        if(n % prime == 0)
            return false;
    }

    return true;
}

/// Get a dynamic array of all primes not exceeding `n`.
pure ulong[] getPrimesUpTo(ulong n)
{
    return getPrimesUpTo(n, [2]);
}

unittest
{
    assert(getPrimesUpTo(1) == []);
    assert(getPrimesUpTo(12) == [2, 3, 5, 7, 11]);
}

/// Get the first `n` primes in a dynamic array.
pure ulong[] getPrimes(ulong n)
{
    return getPrimes(n, [2]);
}

unittest
{
    assert(getPrimes(0) == []);
    assert(getPrimes(5) == [2, 3, 5, 7, 11]);
}

/// Check if `n` is prime.
pure bool isPrime(ulong n)
{
    return isPrime(n, [2]);
}

unittest
{
    assert(!isPrime(0));
    assert(!isPrime(1));
    assert(isPrime(2));
    assert(!isPrime(9));
    assert(isPrime(11));
    assert(!isPrime(42));
    assert(isPrime(43));
}
