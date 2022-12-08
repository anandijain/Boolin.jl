
BOOLEAN_MIN_RULES = [
    @rule((true | (~x)) => true)
    @rule(((~x) | true) => true)
    @rule((false | (~x)) => ~x)
    @rule(((~x) | false) => ~x)
    @rule((true & (~x)) => ~x)
    @rule(((~x) & true) => ~x)
    @rule((false & (~x)) => false)
    @rule(((~x) & false) => false)
    @rule(!(~x) & ~x => false)
    @rule(~x & !(~x) => false)
    @rule(!(~x) | ~x => true)
    @rule(~x | !(~x) => true)
    @rule(xor(~x, !(~x)) => true)
    @rule(xor(~x, ~x) => false)
    @rule(~x == ~x => true)
    @rule(~x != ~x => false)
    @rule(~x < ~x => false)
    @rule(~x > ~x => false)
    @rule (~a | ~b) & (~a | ~c) => ~a | (~b & ~c)
    @rule (~a & ~b) | (~a & ~c) => ~a & (~b | ~c)
    @rule ~a | (~a & ~b) => ~a
    @rule ~a & (~a | ~b) => ~a
    @rule ~a | (!~a & ~b) => ~a | ~b
    @rule ~a & (!~a | ~b) => ~a & ~b
    @rule (~a | ~b) & (!~a | ~b) => ~b
    @rule (~a & ~b) | (!~a & ~b) => ~b
    @rule (~a & ~b) | (!~a & ~c) | (~b & ~c) => (~a & ~b) | (!~a & ~c)
    @rule (~a | ~b) & (!~a | ~c) & (~b | ~c) => (~a | ~b) & (!~a | ~c)
]
chain = Rewriters.Chain(BOOLEAN_MIN_RULES)
SIMPLIFIER = Postwalk(chain)
mysimp(x) = simplify(x; rewriter=SIMPLIFIER)
# SIMPLIFIER2 = Prewalk(chain)

fixed_fs(n) = Symbolics.unwrap.(Boolin.remove_arr_vars(collect(boolean_functions(n))))
nleaves(expr) = length(collect(Leaves(expr)))

fs = fixed_fs(3)
exprs = Symbolics.toexpr.(fs);

fs2 = simplify.(fs; rewriter=SIMPLIFIER);
exprs2 = Symbolics.toexpr.(fs2);
before = nleaves.(exprs)[1:end]
after = nleaves.(exprs2)[1:end]
sum(before) => sum(after) # 7432 => 6513

tt(f7_converted)
x1 - x2 => x1 | !x2
x1(x2 - x3) => x1 & (x2 | !(x3))

x1 - x2 => x1 | !x2

f = fs[31]

f2 = simplify_boolean_function(f)
aa = []
for (i, f) in enumerate(fs)
    @info i, f
    f2 = simplify_boolean_function(f)
    push!(aa, tt(f) == tt(f2))
end

function goodbad(f, xs; verbose=false)
    good = []
    bad = []
    for (i, x) in enumerate(xs)
        verbose && @info x
        try
            y = f(x)
            push!(good, (i, x) => y)
        catch e
            push!(bad, (i, x) => e)
        end
    end
    good, bad
end
gud, bad = goodbad(simplify_boolean_function, fs)


vars = boolean_variables(fs)

aa = []
for goodf in gud
    f = goodf[1][2]
    f2 = last(goodf)
    ftt = tt(f, vars)
    f2tt = tt(f2, vars)
    x = ftt == f2tt
    push!(aa, x)
end
bg = findall(!, aa)
fs2 = simplify_boolean_function.(fs)
fs2 = simplify_boolean_function.(fs)
exprs2 = Symbolics.toexpr.(fs2);
before = nleaves.(exprs)[1:end]
after = nleaves.(exprs2)[1:end]
sum(before) => sum(after) # 7432 => 6513
