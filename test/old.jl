
# 59 but mathematica gives `VertexCount[ExpressionTree[ex2]] == 45`

using Symbolics, SymbolicUtils, Test
@variables x1::Bool
@syms x1::Bool
r = @rule((false & (~x)) => false)
ex = false & x1
r(ex)
# but they have n-arg And, Or
length(collect(Leaves(ex2)))
@variables a::Bool b::Bool c::Bool
ex3 = or(or(a, b), c)
ex4 = |(|(a, b), c)

r = @rule or(or(~a, ~b), ~c) => or(~a, ~b, ~c)
r = @rule or(or(~a, ~b), ~c) => or(~a, ~b, ~c)
r3 = @rule |(|(~a, ~b), ~c) => |(~a, ~b, ~c)
r3 = @rule (~a | ~b) | ~c => |(~a, ~b, ~c)
# r3 = @acrule (~a | ~b) | ~c => |(~a, ~b, ~c)
r(ex3)
ex = r(f3)
r3(ex4)
typeof(r3)

c = Chain([r3])
c(ex4)

using Symbolics, SymbolicUtils
using SymbolicUtils.Rewriters
using Symbolics: unwrap, get_variables
@syms a::Bool b::Bool c::Bool
@variables x::Bool y::Bool z::Bool

r = @rule ~b & ~a => ~a
ex = a & b
@test isequal(r(ex), b)

r2 = @rule (~a | ~b) | ~c => |(~a, ~b, ~c)
ex = (a | b) | c
@which |(a, b, c)
# @edit |(a, b, c) # calls fold so i'll define my own ops
@test isequal(r2(ex), ex)

# or(xs) = or(xs)
@register_symbolic and(x::Bool, y::Bool)::Bool
@register_symbolic and(x)::Bool
@register_symbolic and(x::Vector{Bool})::Bool


@register_symbolic or(xs)::Bool
@register_symbolic or(xs::Vector)::Bool
@register_symbolic or(x, y)::Bool
# @register_symbolic or(x::Vector{Bool})::Bool
@register_symbolic or(xs...)::Bool
@re
@register_symbolic not(x::Bool)::Bool
@register_symbolic or(xs::Vector{SymbolicUtils.Term{Bool,Nothing}})::Bool


or(xs...) = foldl(or, xs)
Base.delete_method(@which or(w...))
# @which or(w...)


ex = or(or(a, b), c)
ex2 = or(a, or(b, c))
r = @rule or(or(~a, ~b), ~c) => or([~a, ~b, ~c])
r = @rule or(or(~a, ~b), ~c) => or(~a, ~b, ~c)
r(ex)
methods(or)
@variables w[1:3]::Bool
or(w)
ex1 = or(w[1], w[2])
wex = unwrap(or(or(w[1], w[2]), w[3]))

r = @rule or(or(~a, ~b), ~c) => or(Symbolics.unwrap(Symbolics.Arr([~a, ~b, ~c])))
r2 = @rule or(or(~a, ~b), ~c) => or(~a, ~b, ~c) # with `or(xs...) = foldl(or, xs)`
@test_throws MethodError r(ex) # MethodError: no method matching or(::Vector{SymbolicUtils.Term{Bool, Nothing}})
r = @rule or(or(~a, ~b), ~c) => [~a, ~b, ~c]
r2 = @acrule or(or(~a, ~b), ~c) => or(~a, ~b, ~c) # with `or(xs...) = foldl(or, xs)`

@register_symbolic foo(a, b)
r2 = @acrule foo(foo(~a, ~b), ~c) => foo(~a, ~b, ~c) # with `or(xs...) = foldl(or, xs)`
expl = foo(foo(w[1], w[2]), w[3])

@test isequal(r2(ex), ex)
@test isequal(r(ex), collect(w))

r = @rule or(~a, ~b) => [~a, ~b]
isequal(r(or(a, b)), [a, b])
r(or(w[1], w[2])) === nothing
r(Symbolics.unwrap(or(w[1], w[2])))

r(ex)

ex = or(or(a, b), c)
ex2 = or(a, or(b, c))
r = @rule or(or(~a, ~b), ~c) => ~a
@test isequal(r(ex), a) && r(ex2) === nothing
acr = @acrule or(or(~a, ~b), ~c) => [~a, ~b, ~c]
@test isequal(acr(ex), [a, b, c])
@test isequal(acr(ex2), [b, c, a])



