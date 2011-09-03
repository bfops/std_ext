module std_ext.math;

public import std.math;
import std.algorithm;

pure ulong sqrt(ulong n)
{
    if(n <= 1)
        return n;

    ulong guess = n / 2;

    while(true)
    {
        ulong newGuess = ((n / guess) + guess) / 2;

        if(newGuess == guess)
            return newGuess;

        guess = newGuess;
    }
}

pure uint sqrt(uint n)
{
    return cast(uint)sqrt(cast(ulong)n);
}

pure ushort sqrt(ushort n)
{
    return cast(ushort)sqrt(cast(ulong)n);
}

pure ubyte sqrt(ubyte n)
{
    return cast(ubyte)sqrt(cast(ubyte)n);
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

/** Get all the primes not greater than `n`.
 *
 * Params: n = No prime greater than this will be found in the collection.
 *
 * Returns: Dynamic array of all the primes not exceeding `n`.
 */
pure ulong[] getPrimesUpTo(ulong n)
{
    if(n < 2)
        return [];

    return getPrimesUpTo(n, [2]);
}

/** Get the first `n` primes.
 *
 * Params: n = Number of primes to get.
 *
 * Returns: Dynamic array of the first `n` primes.
*/
pure ulong[] getPrimes(ulong n)
{
    return getPrimes(n, [2]);
}

/** Check if a number is prime.
 *
 * Params: n = The number to check for primality.
 *
 * Returns: `true` iff `n` is prime.
 */
pure bool isPrime(ulong n)
{
    return isPrime(n, [2]);
}
