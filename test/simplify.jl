using AbstractTrees
using Boolin
using Symbolics
using SymbolicUtils
using SymbolicUtils: Metatheory, Rewriters, Chain, Prewalk, Postwalk, Fixpoint, PassThrough
using Symbolics: unwrap, get_variables, toexpr, symtype
using Groebner, Symbolics, Boolin
using AbstractAlgebra
function getidx_nameof(x)
    x = Symbolics.unwrap(x)
    if istree(x) && operation(x) == getindex
        Symbol(arguments(Symbolics.value(x))...) # x[1] => :x1
    # Symbol(arguments(Symbolics.value(x))[1])
    else
        Symbolics.getname(x)
    end
end

sub_vars(f; kw...) = sub_vars(f, boolean_variables(f); kw...)

function sub_vars(f, vars; T=Bool)
    # new_var_symbols = map(x -> Symbol(arguments(Symbolics.value(x))...), vars)
    new_var_symbols = getidx_nameof.(vars)
    no_getindex_vars = map(x -> only(@variables($x::T)), new_var_symbols)
    sub_dict = Dict(vars .=> no_getindex_vars)
    substitute(f, sub_dict)
end

function remove_arr_vars(f; kw...)
    remove_arr_vars(f, boolean_variables(f); kw...)
end

function remove_arr_vars(f, vars; T=Bool)
    if any(x -> istree(x) && operation(x) == getindex, vars)
        f = sub_vars(f, vars; T)
    end
    f
end

myreverse(r::Metatheory.Rules.AbstractRule) = myreverse(r.expr)

function myreverse(rex)
    args = rex.args
    newex = Expr(:call, args[[1, 3, 2]]...)
    eval(:(@rule $newex))
end

function common_factors(ex)
    splex = split_sum_rule(ex)
    splex === nothing && return ()
    gvars = get_variables.(splex)
    intersect(gvars...)
end

function bad_factor(ex)
    cfs = common_factors(ex)
    isempty(cfs) && return factor(ex)
    for cf in cfs
        ex /= cf
    end
    prod(cfs) * factor(simplify_fractions(ex))#, cfs
end
symtypes(x) = symtype.(boolean_variables(x))
fixed_fs(n) = Symbolics.unwrap.(remove_arr_vars(collect(boolean_functions(n))))

bool_monomial_rules = [
    @rule (!~x) => 1 + ~x
    @rule (~x & ~y) => ~x * ~y
    @rule (~x | ~y) => ~x + ~y
]

factor_rules = [
    @rule ~a * ~b + ~a => ~a * (1 + ~b)
    @rule ~a + ~a * ~b => ~a * (1 + ~b)
    @rule ~a * ~c + ~a * ~b => ~a * (1 + ~b)
    @rule ~a * ~c + ~a * ~b => ~a * (~c + ~b)
    @acrule ~a * ~b + ~a + ~b + 1 => (1 + ~a) * (1 + ~b)
    # @rule + ~a * ~b => ~a * (1 + ~b)
]
not_rules = [
    @rule !~x * ! ~ y => ! ~ x & ! ~ y
    @rule ~x * ! ~ y => ~x & ! ~ y
    @rule !~x * ~y => ! ~ x & ~y
    @rule *(~~xs) => foldl(&, ~~xs)
    @rule (~x)^(~y) => ~x
]
factor_chain = Postwalk(Chain(factor_rules))

factor(x; kws...) = simplify(x; rewriter=factor_chain, kws...)

# r1 = @rule +(~~x) => ~ ~ x
split_sum_rule = @rule +(~~x) => ~ ~ x
c2 = Postwalk(Chain(bool_monomial_rules))
c3 = Prewalk(Chain([split_sum_rule]))

rev_bool_monomial_rules = myreverse.(bool_monomial_rules)
append!(rev_bool_monomial_rules, not_rules)
crev = Postwalk(Chain(rev_bool_monomial_rules))

function simplify_boolean_function_eqs(f)
    sf = simplify(f; rewriter=c2, expand=true)
    vars = boolean_variables(sf)
    sf = sub_vars(sf, vars; T=Real)
    isempty(vars) && return sf # handles false and true case

    if istree(Symbolics.unwrap(sf)) && operation(Symbolics.unwrap(sf)) == +
        sf2 = simplify(sf; rewriter=c3)
    else
        sf2 = sf
    end
    if sf2 isa AbstractArray
        sf2 = collect(sf2)
    else
        sf2 = [sf2]
    end
    sf2 = sub_vars(sf2; T=Bool)
end

function simplify_boolean_eqs(eqs)
    sf2 = eqs
    if istree(sf2) # should be is symbolic maybe
        gb = Symbolics.groebner_basis([sf2])
    else
        gb = Symbolics.groebner_basis(collect(sf2))
    end

    gb = Symbolics.unwrap.(remove_arr_vars.(gb; T=Real))
    bvs = boolean_variables(gb)
    gbs = bad_factor.(gb)
    gbs = sub_vars(gbs; T=Bool)

    sub = Pair{Any,Any}[1.0=>1]
    subs = bvs .=> [only(@variables $x::Bool) for x in Symbolics.getname.(bvs)]
    append!(sub, subs)
    gbs = map(x -> substitute(x, Dict(sub)), gbs)
    gbs = Symbolics.unwrap.(gbs)

    # @info gbs, symtypes(gbs)
    gbss = simplify.(gbs; rewriter=crev)
    length(gbss) == 1 ? only(gbss) : |(gbss...)

end


simplify_boolean_function(f) = simplify_boolean_eqs(simplify_boolean_function_eqs(f))
# "A'BC'D' + AB'C'D' + AB'C'D + AB'CD' + AB'CD + ABC'D' + ABCD' + ABCD"
ts = [4, 8, 9, 10, 11, 12, 14, 15]
X = falses(16)
X[ts.+1] .= true
f = boolean_function(X)
sf = simplify_boolean_function(f)
@test tt(sf) == tt(f)
eqs = simplify_boolean_function_eqs(f)
vars = boolean_variables(f)
_, (x1, x2, x3, x4) = PolynomialRing(QQ, getidx_nameof.(vars))
@variables x1::Bool x2::Bool x3::Bool x4::Bool
eqs = [x1 * x2 * x3 * x4, x1 * x2 * x3 * (1 + x4),
    x1 * x2 * (1 + x3) * (1 + x4),
    x1 * x3 * x4 * (1 + x2),
    x1 * x3 * (1 + x2) * (1 + x4),
    x1 * x4 * (1 + x2) * (1 + x3),
    x2 * (1 + x1) * (1 + x3) * (1 + x4),
    x1 * (1 + x2) * (1 + x3) * (1 + x4)]
gb2 = groebner(eqs)


fs = fixed_fs(3)[1:end]
exprs = Symbolics.toexpr.(fs);
simplify_boolean_function(fs[1]) # UndefKeywordError: keyword argument dims not assigned
simplify_boolean_function(fs[2])
simplify_boolean_function(fs[3])
simplify_boolean_function(fs[7]) #  Failed to apply rule ~x * ~y => ~x & ~y on expression -x2

fs7tt = Bool[0, 0, 0, 0, 0, 1, 1, 0]
f7 = simplify_boolean_function_eqs(fs[7])
tt(fs[7])
eqs = [x1 * x2 * (1 + x3), x1 * x3 * (1 + x2)] # in AA
gb7 = groebner(eqs) # [x1*x3^2 + x1*x3, x1*x2 - x1*x3] 

# f222(x1, x2, x3) = x1 * x3^2 + x1 * x3, x1 * x2 - x1 * x3

# f7_converted = ((x1 & x3) | ((x1 & x2) & !(x1 & x3)))
