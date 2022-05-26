using Test, Symbolics, Boolin, Base.Iterators
fs = boolean_functions(3)

f = boolean_function(falses(8))
@test_throws InexactError boolean_function(falses(7))
@test tt(f) == falses(8)

tts = reduce(hcat, tt.(fs))'
# check function index is correct/consistent with Mathematica
@test evalpoly.(2, reverse.(eachrow(tts))) == 0:255

t = @elapsed boolean_function(100, 30)
@test t < 10
