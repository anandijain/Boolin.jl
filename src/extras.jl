
# boolean_function()


# array_plot(X; kws...) = image(rotr90(.!(X)); interpolate=false, kws...)
# array_plot(O::OEIS.IntegerSequence; kws...) = array_plot(binary_decomp(O.values; kws...); kws...)
# binary_decomp(seq; pad=100) = Bool.(mapreduce(collect ∘ reverse, hcat, digits.(seq; base=2, pad))')

# vv_to_array(xs) = mapreduce(collect ∘ Iterators.reverse, hcat, xs)'
# get_bools2(n) = vv_to_array(get_bools(n))
# plot_seq(seq; kws...) = plot(Gray.(.!binary_decomp(seq; kws...)))
# # get_f(g) = to_func(boolean_function(g))
# # get_vals(g; bs=get_bools_(get_n(g))) = reduce(hcat, get_f(g).(bs))'
# function get_vals(g; bs=get_bools_(get_n(g)))
#     ex = boolean_function(g)
#     x = union(get_variables.(ex)...)
#     vs = map(x0 -> map(ex1 -> substitute(ex1, Dict(x .=> x0)), ex), collect(bs))
#     Bool.(reduce(hcat, vs)')
# end
# tt(ex, vars) = map(x -> substitute(ex, Dict(vars .=> x)), get_bools_(length(vars)))[1:end]
# # to_func(ex) = (xs...) -> substitute(ex, Dict( .=> xs))
# to_func(ex; x=union(get_variables.(ex)...)) = (xs...) -> map(ex1 -> substitute(ex1, Dict(x .=> x0)), ex)

function do_it(g)
    n = get_n(g)
    bs = get_bools_(n)
    fex = boolean_function(g)
    f_ = to_func(fex)
    get_vals(f_, n)
end

function checkit(fs, x, bools, data)
    for h in fs
        if all(Symbolics.value(substitute(h, Dict(x .=> input)) == fx) for (fx, input) in zip(data, bools))
            return h
        end
    end
end

# And(&&,∧) ▪  Or(||,∨) ▪  Not(!,¬) ▪  Nand(⊼) ▪  Nor(⊽) ▪  Xor(⊻) ▫ Xnor() ▪  Implies() ▪  Equivalent(⧦) ▪  Majority

#ac binary
fs = [
    Base.:& => :and,
    Base.:| => :or,
    # Base.xor => :xor, # i
    # Base.:& => "and",
]

for (f, fname) in fs
    ex = :(
        $fname(a, b) = $f(a, b)
    )
    ex2 = :(
        # $fname(a) = $f(a...)
        $fname(a::AbstractArray) = $f(a...)
    )
    eval(ex)
    eval(ex2)
end

and(x, y) = x & y
and(xs...) = Base.:&(xs...)
or(x, y) = x | y
and(xs...) = Base.:&(xs...)
not(x) = !x
xnor(x, y) = !(xor(x, y))
implies(x, y) = or(not(x), y)

@register_symbolic and(x, y)
@register_symbolic or(x, y)
@register_symbolic not(x)
@register_symbolic Base.xor(x, y)
@register_symbolic xnor(x, y)
@register_symbolic implies(x, y)



n_boolean_functions(n) = big(2)^(big(2)^n)

bitsdiff(a, b) = findall(a .!= b)
bitscomm(a, b) = findall(a .== b)

hamming(k, l) = sum(k .!= l)


@register_symbolic (Base.:&)(x, y)::Bool
@register_symbolic (Base.:|)(x, y)::Bool
@register_symbolic (Base.:!)(x)::Bool

@variables x::Bool y::Bool
# @variables x y
@syms a::Bool b::Bool
f1 = x & !x
f2 = a & !a
simplify.([f1, f2])
simplify((x & y) & !(x & y))
simplify((a & b) & !(a & b))

unsimp = fs[1].val
leaves = collect(AbstractTrees.Leaves(unsimp)) # Any[false, x, 1, x, 2] the getindexes are in there :/
nleaves(t) = length(collect(AbstractTrees.Leaves(t)))
#  => length(collect(AbstractTrees.Leaves(simplify(t))))
ts = Symbolics.value.(fs)
xx = nleaves.(ts) .=> nleaves.(simplify.(ts; expand=true))


# print_tree(substitute(unsimp, Dict(Base.:& => Base.:*)))


@syms a::Bool b::Bool
true_ex = (((!(a) & !(b)) | (!(a) & b)) | (a & !(b))) | (a & b)
simplify(true_ex)

(0 | 1) & 1

|(a, b) = a + b - a * b


sorted_boolean_variables(f) = sort!(union(boolean_variables.(f)...), lt=Symbolics.:<ₑ)
sorted_boolean_variables(f2)