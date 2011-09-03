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
    assert(primesCache.length > 0);

    for(ulong i = primesCache[$ - 1]; i <= n; ++i)
        if(isPrime(i, primesCache))
            primesCache ~= i;

    return primesCache;
}

// TODO: Overflow checking with loops.
private pure ulong[] getPrimes(ulong n, ulong[] primesCache)
{
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
    if(n < 2)
        return [];

    return getPrimesUpTo(n, [2]);
}

/// Get the first `n` primes in a dynamic array.
pure ulong[] getPrimes(ulong n)
{
    return getPrimes(n, [2]);
}

/// Check if `n` is prime.
pure bool isPrime(ulong n)
{
    return isPrime(n, [2]);
}
