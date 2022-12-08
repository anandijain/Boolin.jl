# s = "A'BC'D' + AB'C'D' + AB'C'D + AB'CD' + AB'CD + ABC'D' + ABCD' + ABCD"
# vars = Symbol.(unique(filter(isletter, s)))

# for var in vars
#     eval(
#         :($var = only(@variables $var::Bool))
#     )
# end


# :($var = [only(@variables $var::Bool) for $var in $vars])
# ss = split(s, " + ")
# newstrs = []

# function make_expr(exprstr)
#     ms = eachmatch(r"[A-Z]'", exprstr)
#     prod_ms = eachmatch(r"[A-Z][A-Z]", exprstr)
#     ps = []
#     for m in ms
#         str = m.match
#         p = str => "(1+$(str[1]))"
#         push!(ps, p)
#     end
#     # for m in prod_ms
#     #     str = m.match
#     #     p = str => "$(str[1])*$(str[2])"
#     #     push!(ps, p)
#     # end
#     replace(exprstr, ps...)
# end

# for exprstr in ss

#     push!(newstrs, )
# end
# replace()

r = @rule (!~x) => 1 + ~x
c = Postwalk(Chain([r]))
c2 = Postwalk(Chain(bool_monomial_rules))

sf = simplify(f; rewriter=c2)
r2 = @rule(+(~~xs) => ~ ~ xs)
r3 = @rule(|(~~xs) => ~ ~ xs)

c3 = Prewalk(Chain([r2]))
c4 = Prewalk(Chain([r3]))


# g = unwrap(gb[end])
# x[2]*x[3]*x[4] + x[2]*x[3] + x[2]*x[4] + x[2]
# => x[2](x[3]*x[4] + x[3] + x[4] + 1)
# => x[2](x[3](x[4] + 1) + x[4] + 1)
# => x[2](x[3](!x[4]) + !x[4])

acr = @acrule ~a + *(~~x, ~a) => ~a * (1 + ~ ~ x)

ex = a + b * c * a
acr(ex)
simplify(y * a + y * b + y * c; expand=true)
r3 = @rule ~x * +(~~ys) => sum(map(y -> ~x * y, ~~ys))
r4 = myreverse(r3)
r4(ex)

@syms a b c d e f
@variables x1 x2 x3 x4
@variables x1::Bool x2::Bool x3::Bool x4::Bool
ex3 = unwrap(x1 * x2 * x3 + x1 * x2 * x4)
# split_sum_rule(x1 + x2 + x3)
splex = split_sum_rule(g)
gvars = get_variables.(splex)
ixs = intersect(gvars...)
# divex = splex[1] / ;
simplify_fractions(gb[end] / x2) * x2
arrx = @variables zz[1:10]


