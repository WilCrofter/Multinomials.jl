#=

Data structures for exponents and polynomials. Orderings. Arithmetic operations. All experimental. 

=#

import Base.+

type Monomial
    exponent::Array{Int,1}
    coefficient::Number
end

function ltlex(a::Monomial, b::Monomial)
    return lexcmp(b.exponent,a.exponent) == 1
end

typealias Multinomial Array{Monomial,1}

""" collect_terms(a)

Collect terms Monomial array in place, modifying a, and return the length of the valid entries. Entries will be sorted in lexicographically increasing order.

"""
function collect_terms!(A::Multinomial)
    if length(A) <= 1 return A end
    sort!(A,lt=ltlex)
    mt = 0
    current = 1
    for i in 2:length(A)
        if A[i].exponent == A[current].exponent
            # If A[i] has the same exponent as a[current], add the coefficient
            # of A[i] to that of A[current]. If mt=0 set mt=i.
            A[current].coefficient += A[i].coefficient
            if mt == 0 mt = i end
        elseif mt > 0
            # Else, if mt > 0, set A[mt] = A[i], set current = mt,
            # and set mt = mt+1. Note mt < i always.
            A[mt] = A[i]
            current = mt
            mt += 1
        end
    end
    return current
end

function +(A::Multinomial, B::Multinomial)
    C = vcat(A,B)
    n = collect_terms!(C)
    return C[1:n]
end
    
            
