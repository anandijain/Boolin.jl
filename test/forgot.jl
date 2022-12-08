using Boolin
importall!(Boolin)
n=3;m=2;
bs = collect(boolean_functions(n, m));
length(bs) == (2^m)^(2^n) 



mapreduce(tt, hcat, (bss[1]))'


"finds the number of variables needed to represent a boolean function of value n"
nvars(n) = Int(log2(nextpow(2, n)))

Boolin.boolean_function(k::Integer) = boolean_function(ith_bools(k, nvars(k)))
k = 30
bf = boolean_function(k)
@assert k == Symbolics.value(evalpoly(2, reverse(tt(bf)) + 1))

"number of truth tables of n boolean variables"
nb(n) = nb(n, 1)
nb(n, m) = (2^m)^(2^n)
nb(n, m) = nb(n)^m
nbn(n) = nb(n,n)

# trying to figure out if the number of unique state transition graphs is
nbu(n, m) = binomial(nb(n), m)
# or
# nbu(n,m) = nb(n,m)/factorial(m)
nbu(n) = nbu(n,n)

# n_boolean_functions(n) = 