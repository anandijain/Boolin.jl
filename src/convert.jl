
struct BooleanForm{T} end
form_modes = [
("DNF", "disjunctive normal form, sum of products")

("CNF", "conjunctive normal form, product of sums")

("ESOP", "exclusive sum of products")

("ANF", "algebraic normal form")

("NOR", "two-level Nor and Not")

("NAND", "two-level Nand and Not")

("AND", "two-level And and Not")

("OR", "two-level Or and Not")
# "IMPLIES"
# Implies and Not
# "ITE","IF"
# If and constants
# "BFF"
# BooleanFunction form
# "BDT"
]
for m in form_modes
    s, doc = m
    s = Symbol(s)
    s2 = Symbol("BoolForm", s)
    doc = "\t $s2\n $doc"
    eval(:(@doc $doc const $s2 = BooleanForm{:($s)}()))
end


