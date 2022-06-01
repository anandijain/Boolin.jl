"
generates all boolean functions with the symbols x, will be 2^(2^(length(x)))

https://oeis.org/A001146
"
function boolean_functions(x)
    # fs = Num[]
    n = length(x)
    tups = _get_tups(x)
    bs = bool_itr(2^n)
    # for b in bs
    #     t = boolean_function(x, tups, b)
    #     push!(fs, t)
    # end
    # fs
    (boolean_function(x, tups, b) for b in bs)
end

boolean_functions(n::Integer) = boolean_functions(make_boolean_variables(n))
"https://oeis.org/A057156"
boolean_functions(n::Integer, m::Integer) = boolean_functions(make_boolean_variables(n), m)

function boolean_functions(x, m::Integer)
    fs = boolean_functions(x)
    product(Iterators.repeated(fs, m)...)
end

"is (f1, f2, f3) the same as (f1, f3, f2)?"
function unique_boolean_functions(n, m)
    fs = boolean_functions(n)
    combinations(fs, m)
end

function tt(f, x)
    map(b -> substitute(f, Dict{Num,Bool}(x .=> b)), bools(length(x)))[begin:end]
end

"truth table"
tt(f) = tt(f, boolean_variables(f))
tt(f, n::Integer) = tt(f, make_boolean_variables(n))

"returns in DNF, unjoined"
boolean_function(x, tups, b) = boolean_function!([], x, tups, b)
function boolean_function!(t, x, tups, b)
    for (a, y) in zip(tups, b)
        if y
            push!(t, reduce(&, a))
        end
    end
    _fix(t, x)
end

function boolean_function(vars, vals)
    boolean_function(vars, _get_tups(vars), vals)
end

function boolean_function(vals)
    n = Int(log2(length(vals)))
    boolean_function(make_boolean_variables(n), vals)
end

boolean_function(args...) = boolean_function(args)

"""
    boolean_function(k::Integer, n::Integer)

this will give the boolean function corresponding to the truth table of the binary decomposition of `k-1`

note that this is different from Mathematica's `BooleanFunction` which is the function corresponding to the binary decomposition of `k`.
"""
boolean_function(k::Integer, n::Integer) = boolean_function(ith_bools(k, n))
binary_decomposition(k, n) = reverse!(digits(Bool, k; base=2, pad=n))
binary_decomposition(k) = binary_decomposition(k, 0)
ith_bools(k, n) = binary_decomposition(k - 1, 2^n)
from_bools!(bs) = evalpoly(2, reverse!(bs))
from_bools(bs) = evalpoly(2, reverse(bs))
# from_bools(bs) = evalpoly(2, Iterators.reverse(bs))

function boolean_variables(f)
    sort!(Symbolics.get_variables(f); lt=Symbolics.:<ₑ)
end
boolean_variables(f::AbstractArray) = sort!(union(boolean_variables.(f)...), lt=Symbolics.:<ₑ)

make_boolean_variables(n::Integer) = collect(first(@variables x[1:n]::Bool))

"makes evaluating a bit easier than using `substitute` directly"
struct BooleanFunction
    f
end
BooleanFunction(k, n) = BooleanFunction(boolean_function(k, n))
(f::BooleanFunction)(d::Dict) = substitute(f.f, d)
# (f::BooleanFunction)(x, b) = f(Dict(x .=> b))
(f::BooleanFunction)(x, b) = substitute(f.f, Dict(x .=> b))
(f::BooleanFunction)(x) = substitute(f.f, Dict(boolean_variables(f) .=> x))
(f::BooleanFunction)(x...) = f(x)
tt(f::BooleanFunction) = tt(f.f)
boolean_variables(f::BooleanFunction) = boolean_variables(f.f)

_fix(t) = isempty(t) ? false : reduce(|, t)
_fix(t, tup) = isempty(t) ? reduce(&, (false, tup...)) : reduce(|, t)

"""
The first iterator changes the fastest in Iterators.product so
Iterators.product does not behave the same as Python's itertools product
"""
function _get_tups(x)
    rx = reverse(x)
    Iterators.map(Iterators.reverse, product(Iterators.zip(Base.:!.(rx), rx)...))
end
