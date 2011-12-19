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

/// This struct is for handling rational numbers without data loss in non-integers.
struct Fraction
{
    immutable static Fraction undefined = Fraction(1, 0);
    immutable static Fraction zero = Fraction(0, 1);

    long numerator;
    ulong denominator;

    /// Reduce this fraction to lowest terms.
    pure void reduce()
    {
        ulong[] primes = getPrimesUpTo(sqrt(max(abs(this.numerator), this.denominator)));

        foreach(prime; primes)
            while(this.numerator % prime == 0 && this.denominator % prime == 0)
        {
            this.numerator /= prime;
            this.denominator /= prime;
        }
    }

    /// Get the current fraction, reduced to lowest terms.
    const pure Fraction getReduced()
    {
        Fraction ret = this;
        ret.reduce();

        return ret;
    }

    /// Is this fraction undefined?
    const pure bool isUndefined()
    {
        return (this.denominator == 0);
    }

    const pure Fraction opUnary(string s : "+")()
    {
        return this;
    }

    const pure Fraction opUnary(string s : "-")()
    {
        static assert(this.numerator.min < 0);
        static assert(this.numerator.max > 0);
        static assert(this.numerator.min + this.numerator.max == -1);

        if(this.numerator == this.numerator.min)
        {
            Fraction f = this.getReduced();
            return Fraction(-f.numerator, f.denominator);
        }

        return Fraction(-this.numerator, this.denominator);
    }

    const pure Fraction opBinary(string s : "+")(Fraction f);

    const pure Fraction opBinary(string s : "-")(Fraction f)
    {
        static assert(numerator.min < 0);
        static assert(numerator.max > 0);
        static assert(numerator.min + numerator.max == -1);

        if(f.numerator == f.numerator.min)
            return this + -Fraction(-1, f.denominator) + -Fraction(f.numerator.max, f.denominator);

        return this + -f;
    }

    const pure Fraction opBinary(string s : "*")(Fraction f)
    {
        static pure bool causesOverflow(Fraction arg1, Fraction arg2)
        {
            assert(arg1 != 0);
            assert(arg2 != 0);
            assert(!arg1.isUndefined());
            assert(!arg2.isUndefined());

            static assert(typeof(Fraction.numerator).min + typeof(Fraction.numerator).max == -1);
            static assert(typeof(Fraction.numerator).max > 0);
            static assert(typeof(Fraction.numerator).min < 0);

            // if(arg2.denominator * arg1.denominator > denominator.max)
            if(typeof(Fraction.denominator).max / arg1.denominator < arg2.denominator)
                return true;

            // If exactly one numerator is negative.
            if((arg1.numerator < 0) ^ (arg2.numerator < 0))
                // We use max() so that we divide by the positive number, and don't flip the inequality's direction.
                // if(arg1.numerator * arg2.numerator < numerator.min)
                return (typeof(Fraction.numerator).min / max(arg1.numerator, arg2.numerator) > min(arg1.numerator, arg2.numerator));

            // If one of them is negative, both must be (since we've handled the "exactly one" case).
            // We can't multiply `numerator.min` by a negative and get a non-overflowed (positive) result.
            if(arg1.numerator == typeof(Fraction.numerator).min || arg2.numerator == typeof(Fraction.numerator).min)
                return true;

            // We use abs(), because dividing by a negative would flip the inequality's direction.
            return (typeof(Fraction.numerator).max / abs(arg1.numerator) < abs(arg2.numerator));
        }

        static void reduceAsNecessary(ref Fraction arg1, ref Fraction arg2, bool tryCrossReduce = true)
        {
            if(causesOverflow(arg1, arg2))
            {
                arg1.reduce();

                if(causesOverflow(arg1, arg2))
                {
                    arg2.reduce();

                    if(tryCrossReduce && causesOverflow(arg1, arg2))
                    {
                        // Cross-reduction.
                        swap(arg1.denominator, arg2.denominator);

                        reduceAsNecessary(arg1, arg2, false);
                    }
                }
            }
        }

        if(this.isUndefined() || f.isUndefined())
            return undefined;

        if(this == 0 || f == 0)
            return zero;

        Fraction arg1 = this;
        reduceAsNecessary(arg1, f);

        return Fraction(arg1.numerator * f.numerator, arg1.denominator * f.denominator);
    }

    const pure Fraction opBinary(string s : "/")(Fraction f)
    {
        static pure Fraction reciprocate(Fraction f)
        {
            assert(f.denominator <= f.numerator.max);

            if(f < 0)
                return Fraction(-f.denominator, -f.numerator);

            return Fraction(f.denominator, f.numerator);
        }

        static pure bool cannotDelegateToMultiply(Fraction arg1, Fraction arg2)
        {
            return (arg1.denominator > arg1.numerator.max && arg2.denominator > arg2.numerator.max);
        }

        static void reduceAsNecessary(ref Fraction arg1, ref Fraction arg2)
        {
            if(cannotDelegateToMultiply(arg1, arg2))
            {
                arg1.reduce();

                if(cannotDelegateToMultiply(arg1, arg2))
                {
                    arg2.reduce();

                    ulong[] primes = getPrimesUpTo(sqrt(max(abs(arg1.denominator), arg2.denominator)));

                    foreach(prime; primes)
                        while(arg1.denominator % prime == 0 && arg2.denominator % prime == 0)
                    {
                        arg1.denominator /= prime;
                        arg2.denominator /= prime;
                    }
                }
            }
        }

        static assert(denominator.max + denominator.min == -1);

        if(this.isUndefined() || f.isUndefined())
            return undefined;

        Fraction arg1 = this;
        reduceAsNecessary(arg1, f);

        if(f.denominator <= f.numerator.max)
            return this * reciprocate(f);

        return f * reciprocate(this);
    }

    const pure Fraction opBinary(string s)(long n)
    {
        return this.opBinary!(s)(Fraction(n, 1));
    }

    const pure Fraction opBinaryRight(string s)(long n)
    {
        return Fraction(n, 1).opBinary!(s)(this);
    }

    const pure bool opCast(T : bool)()
    {
        return (numerator != 0 || isUndefined());
    }

    const pure real opCast(T : real)()
    {
        if(isUndefined())
            return real.nan;

        return cast(real)numerator / denominator;
    }

    const pure bool opEquals(ref const Fraction f)
    {
        if(isUndefined() || f.isUndefined())
            return false;

        if(numerator == 0)
            return (f.numerator == 0);

        return this / f == 1;
    }

    const pure bool opEquals(long n)
    {
        if(isUndefined())
            return false;

        if(numerator == 0)
            return (n == 0);

        // TODO: Overflow check;
        return (denominator * n == numerator);
    }

    const pure bool opEquals(real r)
    {
        if(isUndefined())
            return false;

        // TODO: Overflow check;
        return (cast(real)this == r);
    }

    const pure int opCmp(ref const Fraction f);
    const pure int opCmp(long n);
}

unittest
{
    assert(Fraction(1, 2) == Fraction(2, 4));
    assert(+Fraction(1, 2) == Fraction(1, 2));
    assert(-Fraction(1, 2) == Fraction(-1, 2));

    assert(Fraction(1, 3) == 1.0L / 3);
    assert(Fraction(1, 1) == 1);
    assert(Fraction(1, 2));
    assert(!Fraction(0, 1));

    assert(Fraction(1, 2) + Fraction(2, 3) == Fraction(7, 6));
    assert(Fraction(7, 6) - Fraction(2, 3) == Fraction(1, 2));
    assert(Fraction(1, 2) * Fraction(2, 3) == Fraction(1, 3));
    assert(Fraction(1, 3) / Fraction(1, 2) == Fraction(2, 3));

    assert(Fraction(1, 2) + 1 == Fraction(3, 2));
    assert(Fraction(3, 2) - 1 == Fraction(1, 2));
    assert(Fraction(1, 3) * 2 == Fraction(2, 3));
    assert(Fraction(2, 3) / 2 == Fraction(1, 3));

    assert(1 + Fraction(1, 2) == Fraction(3, 2));
    // TODO: Fix to ` == -Fraction(1, 2)`.
    assert(-(1 - Fraction(3, 2)) == Fraction(1, 2));
    assert(2 * Fraction(1, 3) == Fraction(2, 3));
    assert(2 / Fraction(2, 3) == Fraction(3, 1));

    // TODO: Overflow-handling tests.
}
