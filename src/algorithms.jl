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


"""
function buchberger(F::Array{Multinomial,1})

Buchberger's algorithm for finding a Groebner basis for the ideal generated by the system of multinomials, F.

This is a straightforward, unoptimized implementation of the algorithm as described by Buchberger himself in [Gröbner Bases: A Short Introduction for Systems Theorists](http://link.springer.com/chapter/10.1007/3-540-45654-6_1)[PDF](http://people.reed.edu/~davidp/pcmi/buchberger.pdf) as follows:

Start with G = F .
For any pair of polynomials f1 , f2 in G:
  Compute the S✁polynomial of f1, f2
  and reduce it to a reduced form h w.r.t. G.
  If h is not 0, consider the next pair.
  If h ✑ 0, add h to G and iterate.

Note that G never shrinks. In the worst case it can become intractably large. Moreover, the final G may contain many redundant multinomials. Neither of these problems aare faced here.
"""
function buchberger(F::Array{Multinomial,1}; increment=1000, maxiterations=1000,
                    D = nothing)
    ## Initialization ##
    # Expandable storage for Groebner basis
    nG = max(length(F), increment)
    iG = length(F)
    G = Array(Multinomial, nG)
    # Initialize G = F
    for i in 1:iG G[i] = deepcopy(F[i]) end
    # Random permutation for choosing pairs
    nP = binomial(iG,2)
    P = randperm(nP)
    iP = 1
    # Expandable storage for (hashes of) discarded pairs
    if D == nothing
        nD = max(binomia(length(F),2), increment)
        iD = 0
        D = Array(UInt,nP)
    else
        iD = length(D)+1
        D = vcat(D, Array(UInt, increment))
        nD = length(D)
    end
    ## Main loop ##
    iteration = 0
    # Continue while undiscarded pairs are available and maxinterations
    # are not exceeded.
    while iD < binomial(iG, 2) && iteration <= maxiterations
        # Choose an undiscarded pair of multinomials in G
        pair,iP = pair!(P, iP)
        while findfirst(D[1:iD], hash(pair)) > 0
            pair,iP = pair!(P, iP)
        end
        f1 = G[pair[1]]
        f2 = G[pair[2]]
        # Compute their S-polynomial
        S = S_poly(f1,f2)
        # Reduce S by G
        # bookkeeping
        iteration += 1
    end
    # Return current states of G and D
    return G[1:iG], D[1:iD]
end

function pair!(P::Array{Int,1},iP::Int)
    if iP > length(P)
        P = randperm(length(P))
        iP = 1
    end
    pair = (P[iP],P[iP+1]), iP+1
    return pair, iP
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


