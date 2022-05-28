using Test, Symbolics, Boolin, Base.Iterators

n = 3
x = collect(first(@variables x[1:n]::Bool))

f = x[1]
@test tt(f) == [false, true]
f = Num(false)
@test_broken tt(f) == [false, false]; # there are no Symbolic variables in the expression
# @test tt(f) == [false]; # weird show bug in AbstractAlgebra.jl
@test tt(f, 1) == [false, false] # we can provide the arity of the expression
@test tt(f, x[1]) == [false, false] # or the variables
@test tt(f, [x[1], x[2]]) == falses(4)

fs = boolean_functions(n)
vars = boolean_variables.(fs)
@test isequal(vars[1], x) && allequal(vars) # sorted [x[1], x[2], x[3]]

f = fs[3] # (x[1] & x[2]) & !(x[3])
bf = BooleanFunction(f)
@test bf(true, true, false) isa Num
@test Bool(bf(true, true, false))

# checking function index is correct/consistent with Mathematica
# fs = Table[BooleanFunction[i, 2], {i, 0, 2^(2^2) - 1}]
# Map[x | -> FromDigits[Boole[BooleanTable[x]], 2], fs]
bfs = BooleanFunction.(fs)
bs = bools(n)
tts = map(f -> f.(bs), bfs)
@test from_bools.(tts) == 0:255
@test from_bools.(tt.(fs)) == 0:255

f = boolean_function(falses(8)) # function from values
@test_throws InexactError boolean_function(falses(7)) # incomplete tables not implemented

@test Bool(BooleanFunction(3, 2)(bools(2)[3]))

# make sure getting functions with large number of variables isn't too slow
t = @elapsed boolean_function(100, 30)
@test t < 10
