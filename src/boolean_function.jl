"generates all boolean functions with the symbols x, will be 2^(length(x))"
function boolean_functions(x)
    fs = Num[]
    n = length(x)
    tups = _get_tups(x)
    bs = bool_itr(2^n)
    for b in bs
        t = boolean_function(x, tups, b)
        push!(fs, _fix(t))
    end
    fs
end
boolean_functions(n::Integer) = boolean_functions(collect(first(@variables x[1:n]::Bool)))

"truth table"
function tt(ex)
    vars = Symbolics.get_variables(ex)
    n = length(vars)
    map(x -> substitute(ex, Dict(vars .=> x)), bool_itr(n))[1:end]
end

function boolean_function(vars, vals)
    boolean_function(vars, _get_tups(vars), vals)
end

function boolean_function(vals)
    n = Int(log2(length(vals)))
    vars = collect(first(@variables x[1:n]::Bool))
    boolean_function(vars, vals)
end

boolean_function(args...) = boolean_function(args)
boolean_function(k::Integer, n::Integer) = boolean_function(ith_bools(k, n))
ith_bools(k, n) = reverse!(digits(Bool, k - 1; base=2, pad=2^n))

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

_fix(t) = isempty(t) ? false : reduce(|, t)
_fix(t, tup) = isempty(t) ? reduce(&, (false, tup...)) : reduce(|, t)
_get_tups(x) = Iterators.map(Iterators.reverse, product(Iterators.zip(Base.:!.(x), x)...))
