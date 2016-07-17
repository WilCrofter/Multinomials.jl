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

""" collect_terms(a)

Collect terms of a sorted Monomial array in place, modifying a,
and return the length of the valid entries.

"""
function collect_terms!(a::Array{Monomial,1})
    if length(a) <= 1 return a end
    mt = 0
    current = 1
    for i in 2:length(a)
        if a[i].exponent == a[current].exponent
            # If a[i] has the same exponent as a[current], add the coefficient
            # of a[i] to that of a[current]
            a[current].coefficient += a[i].coefficient
            if mt == 0 mt = i end
        elseif mt > 0
            # Else, if mt > 0, set a[mt] = a[i], set current = mt,
            # and set mt = mt+1
            a[mt] = a[i]
            current = mt
            mt += 1
        end
    end
    return current
end

