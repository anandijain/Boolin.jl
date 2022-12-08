x = vars = collect(first(@variables x[1:7]))

@btime Boolin._get_tups(x[1:2])
@btime Boolin._get_tups(x[1:3])
@btime Boolin._get_tups(x[1:4])
@btime Boolin._get_tups(x[1:5])
@btime Boolin._get_tups(x[1:6])
@btime Boolin._get_tups(x[1:7])

@btime boolean_function(1, 1);
@btime boolean_function(1, 2);
@btime boolean_function(1, 3);
@btime boolean_function(1, 4);
@btime boolean_function(1, 5);
@btime boolean_function(1, 6);
@btime boolean_function(1, 7);
@btime boolean_function(100, 20);


@profview_allocs boolean_function(1, 6)
ProfileCanvas.@profview boolean_function(1, 7)
ProfileCanvas.@profview boolean_function(1, 6)


getbs(k, n) = collect(first(Iterators.drop(bool_itr(2^n), k - 1)))
function bs2(k, n)
    # zeros(n)
    reverse(digits(k - 1; base=2, pad=2^n))
end

@btime getbs(1, 1); # 589.583 ns (11 allocations: 368 bytes)
@btime getbs(1, 2); # 794.606 ns (15 allocations: 512 bytes)
@btime getbs(1, 3); # 1.117 μs (23 allocations: 800 bytes)
@btime getbs(1, 4); # 1.850 μs (39 allocations: 1.38 KiB)
@btime getbs(1, 5); # 4.944 μs (76 allocations: 4.36 KiB)
@btime getbs(1, 6); # 98.542 μs (2347 allocations: 109.89 KiB)
@btime getbs(1, 7)

@btime bs2(1, 1); # 589.583 ns (11 allocations: 368 bytes)
@btime bs2(1, 2); # 794.606 ns (15 allocations: 512 bytes)
@btime bs2(1, 3); # 1.117 μs (23 allocations: 800 bytes)
@btime bs2(1, 4); # 1.850 μs (39 allocations: 1.38 KiB)
@btime bs2(1, 5); # 4.944 μs (76 allocations: 4.36 KiB)
@btime bs2(1, 6); # 98.542 μs (2347 allocations: 109.89 KiB)
@btime bs2(1, 7)
ts = [
    589.583u"ns"
    794.606u"ns"
    1.117u"μs"
    1.850u"μs"
    4.944u"μs"
    98.542u"μs"
]
@test_throws DimensionError plot(eachindex(ts), ts)

plot(eachindex(ts), ustrip.(ts))

using ProfileCanvas

@time boolean_function(100, 20)
ProfileCanvas.@profview boolean_function(100, 30)

@benchmark boolean_function(100, 30)

@btime boolean_function(100, 30)
k = 100
n = 30
digs = digits(k - 1; base=2, pad=2^n) 
@btime digits(k - 1; base=2, pad=2^n) #  5.356 s (5 allocations: 8.00 GiB)
@btime digits(Bool, k - 1; base=2, pad=2^n) # 1.203 s (5 allocations: 1.00 GiB)
@btime reverse($digs) #  7.594 s (2 allocations: 8.00 GiB)
@btime reverse!($digs) # 2.392 s (0 allocations: 0 bytes)
ith_bools(k, n) = BitVector(reverse())
ith_bools(k, n) = BitVector(reverse!(digits(k - 1; base=2, pad=2^n)))
