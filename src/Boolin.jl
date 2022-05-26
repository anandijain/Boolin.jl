module Boolin

using Base.Iterators
using Symbolics

# @register_symbolic (Base.:&)(x, y)
# @register_symbolic (Base.:|)(x, y)
# @register_symbolic (Base.:!)(x)

_bool_itr(n) = product(repeated(Bool[0, 1], n)...)
bool_itr(n) = Iterators.map(Iterators.reverse, _bool_itr(n))
itr_to_matrix(xs) = mapreduce(collect ∘ Iterators.reverse, hcat, xs)'
bools(n) = itr_to_matrix(_bool_itr(n))

include("boolean_function.jl")

export bool_itr, bools, tt, boolean_function, boolean_functions

end # module
