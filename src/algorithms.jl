
function S_poly(A::Multinomial, B::Multinomial)
    x = A[end].indeterminate
    tmp = [max(A[end].exponent[i], B[end].exponent[i]) for i in 1:x.degree]
    return B[end].coefficient*x^(tmp-A[end].exponent)*A -
        A[end].coefficient*x^(tmp-B[end].exponent)*B
end

"""
Does monomial a divide monomial b?
"""
function divides(a::Monomial, b::Monomial)
   !isapprox(a.coefficient, 0) &&
       all(a.exponent .<= b.exponent) &&
       a.indeterminate == b.indeterminate
end

"""
Quotient of b and a. Assumes divisability
"""
function /(b::monomial, a::monomial)
    Monomial(b.indeterminate,
             b.exponent-a.exponent,
             b.coefficient/a.coefficient)
end



function demo_alg()
    @show x = Indeterminate(3)
    println()
    @show A = 1 + 2*x^[1,2,3] + 3*x^[3,2,1]
    println()
    @show B = 2 + 5* x^[1,3,2]
    println()
    @show S_poly(A,B)
end

#=
Start with G = F .
For any pair of polynomials f1 , f2 in G:
  Compute the S✁polynomial of f1 , f2
  and reduce it to a reduced form h w.r.t. G.
  If h is not 0, consider the next pair.
  If h ✑ 0, add h to G and iterate.
=#
