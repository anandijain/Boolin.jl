# Boolin.jl

utilities for working with boolean functions 

sort of mirrors `BooleanFunction` in Mathematica

not implemented: `BooleanConvert`, `BooleanMinimize`, visualization, SAT, `FindInstance`, monotonicity, `boolean_function` on incomplete truth tables

`boolean_function` shouldn't be too slow for up to 30 variables

notes:
`BooleanTable` goes in `Tuples[{True,False},n]` order, but Boolin.jl `tt` is ascending, ie (00, 01, 10, 11)

`BooleanFunction[k, n]` is zero based, where the truth table is the binary decomposition of k, not k-1, as i do.

the distinction is my `boolean_function` is "give me the k-th boolean function in n variables", not "give me the boolean function for k's digits"
