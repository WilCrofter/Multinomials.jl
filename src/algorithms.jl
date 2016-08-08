import Base./


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
function /(b::Monomial, a::Monomial)
    Monomial(b.indeterminate,
             b.exponent-a.exponent,
             b.coefficient/a.coefficient)
end

""" function reduce(A::Multinomial, B::Multinomial)

Reduce A by B. Assumes divisibility of A[end] by B[end]
"""
function reduce(A::Multinomial, B::Multinomial)
    A - (A[end]/B[end])*B
end

""" function reduce(A::Multinomial, G::Array{Multinomial,1})

Reduce A by putative Groebner basis, G
"""
function reduce(A::Multinomial, G::Array{Multinomial,1})
    h = deepcopy(A)
    for g in G
        if divides(g[end], h[end])
            h = reduce(h, g)
        end
    end
    return h
end

""" function iszero(A::Multinomial)

Is multinomial A zero?
"""
function iszero(A::Multinomial)
    length(A)==0 || (length(A)==1 && isapprox(A[1].coefficient, 0))
end

"""
function buchberger(F::Array{Multinomial,1})

Buchberger's algorithm for finding a Groebner basis for the ideal generated by the system of multinomials, F.

This is a straightforward, unoptimized implementation of the algorithm as described by Buchberger himself in [Gröbner Bases: A Short Introduction for Systems Theorists](http://link.springer.com/chapter/10.1007/3-540-45654-6_1)[PDF](http://people.reed.edu/~davidp/pcmi/buchberger.pdf) as follows:

Start with G = F .
For any pair of polynomials f1 , f2 in G:
  Compute the S✁polynomial of f1, f2
  and reduce it to a reduced form h w.r.t. G.
  If h = 0, consider the next pair.
  If h is not 0, add h to G and iterate.

Note that G never shrinks. In the worst case it can become intractably large. Moreover, the final G may contain many redundant multinomials. Neither of these problems aare faced here.
"""
function buchberger(F::Array{Multinomial,1};
                    increment::Int=1000,
                    maxiterations::Int=1000,
                    # for re-entry:
                    p1::Int=1,
                    p2::Int=2)
    ## Initialization ##
    # Expandable storage for Groebner basis
    nG = max(length(F), increment)
    iG = length(F)
    G = Array(Multinomial, nG)
    # Initialize G = F
    for i in 1:iG G[i] = deepcopy(F[i]) end
    ## Main loop ##
    iteration = 1
    # Continue while new pairs are available and max iterations
    # are not exceeded.
    while p2 <= iG && iteration <= maxiterations
        f1 = G[p1]
        f2 = G[p2]
        # Compute their S-polynomial
        S = S_poly(f1,f2)
        # Reduce S by G
        h = reduce(S, G[1:iG])
        if !iszero(h)
            iG += 1
            if iG > length(G)
                G = vcat(G,Array(Monomial, increment))
            end
            G[iG] = h
        end
        # bookkeeping
        iteration += 1
        # next pair: note p2 increments more slowly than p1
        # so that all pairs p1 < p2 <= k are covered before
        # pairs p1 < p2 = k+1 are reached.
        p1, p2 = p1+1 < p2 ? (p1+1,p2) : (1, p2+1)
    end
    # Return G, p1, p2
    return G, iG, p1, p2
end


function pair!(P::Array{Int,1},iP::Int)
    if iP > length(P)
        P = randperm(length(P))
        iP = 1
    end
    pair = P[iP] < P[iP+1]? (P[iP],P[iP+1]) : (P[iP+1], P[iP])
    return pair, iP+2
end

function demo_alg()
    @show x = Indeterminate(3)
    println()
    @show A = 1 + 2*x^[1,2,3] + 3*x^[3,2,1]
    println()
    @show B = 2 + 5* x^[1,3,2]
    println()
    @show S_poly(A,B)
    F = Array(Multinomial,2)
    F[1] = A; F[2] = B
    println()
    @show F
    println()
    G, iG, p1, p2 = buchberger(F, maxiterations=10)
    @show iG, p1, p2
    println()
    @show G[iG]
end

function demo_bb()
    @show x = Indeterminate(2)
    println()
    @show A = x^[2,2] + x^[1,1]
    println()
    @show B = x^[0,4] - x^[0,2]
    println()
    F = Array(Multinomial,2)
    F[1] = A; F[2] = B
    println()
    @show F
    println()
    G, iG, p1, p2 = buchberger(F, maxiterations=50)
    @show iG, p1, p2
    println()
    for i in 1:iG @show G[i] end
end

function bug1()
    x=Indeterminate(2)
    @show -x^[0,2]
    println()
    @show x^[0,4]-x^[0,2]
    println()
    @show -(x^[0,4],x^[0,2])
    nothing
end
    
    
    


