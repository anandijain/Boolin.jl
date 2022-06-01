module Boolin

using Base.Iterators
using Symbolics
using Combinatorics

# @register_symbolic (Base.:&)(x, y)::Bool
# @register_symbolic (Base.:|)(x, y)::Bool
# @register_symbolic (Base.:!)(x)::Bool

_bool_itr(n) = product(repeated(Bool[0, 1], n)...)
bool_itr(n) = Iterators.map(Iterators.reverse, _bool_itr(n))
itr_to_matrix(xs) = mapreduce(collect ∘ Iterators.reverse, hcat, xs)'
bool_matrix(n) = itr_to_matrix(_bool_itr(n))
bools(n) = collect.(bool_itr(n))[begin:end]

include("boolean_function.jl")

export bool_itr, bools, bool_matrix, tt, boolean_function, boolean_functions, BooleanFunction
export binary_decomposition, ith_bools, from_bools, boolean_variables, make_boolean_variables

end # module
