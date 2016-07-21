#=

Data structures for exponents and polynomials. Orderings. Arithmetic operations. All experimental. 

=#

import Base.+, Base.*, Base.-, Base.^

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
        else
            current = i
        end
    end
    # eliminate 0 terms
    mt = 0
    n = 0
    for i = 1:current
        if isapprox(A[i].coefficient, 0)
            if mt == 0
                mt = i
            end
        elseif mt > 0
            A[mt] = A[i]
            n = mt
            mt += 1
        else
            n = i
        end
    end
    return max(1,n) # return at least 1 term, even if 0.
end


function +(A::Multinomial, B::Multinomial)
    C = deepcopy(vcat(A,B))
    n = collect_terms!(C)
    return C[1:n]
end

function *(A::Multinomial, B::Multinomial)
    na = length(A)
    nb = length(B)
    C = Array(Monomial, na*nb)
    for i in 1:na
        Ae = A[i].exponent
        Ac = A[i].coefficient
        offset = (i-1)*nb
        for j in 1:nb
            C[j+offset] = Monomial(Ae+B[j].exponent, Ac*B[j].coefficient)
        end
    end
    n = collect_terms!(C)
    return C[1:n]
end

# syntactic sugar

function -(a::Monomial)  Monomial(a.exponent, -a.coefficient) end

function -(A::Multinomial)
    B = deepcopy(A)
    for b in B
        b.coefficient = -b.coefficient
    end
    return B
end

function -(A::Multinomial, B::Multinomial)
    C = vcat(deepcopy(A), -(B)) # -() deepcopies B
    n = collect_terms!(C)
    return C[1:n]
end

+(A::Monomial, B::Multinomial) = [A] + B
+(A::Multinomial, B::Monomial) = A + [B]
+(A::Monomial, B::Monomial)    = [A] + [B]
-(A::Monomial, B::Multinomial) = [A] - B
-(A::Multinomial, B::Monomial) = A + [B]
-(A::Monomial, B::Monomial)    = [A] + [B]
*(A::Monomial, B::Multinomial) = [A]*B
*(A::Multinomial, B::Monomial) = A*[B]
*(A::Monomial, B::Monomial)    = [A]*[B]

+(x::Number, a::Monomial) = Monomial(zeros(Int,length(a.exponent)), x) + a
+(a::Monomial, x::Number) = x+a
+(x::Number, A::Multinomial) = Monomial(zeros(Int,length(A[1].exponent)), x)+A
+(A::Multinomial, x::Number) = x + A
-(x::Number, a::Monomial) = (-a)+x
-(a::Monomial, x::Number) = a+(-x)
-(x::Number, A::Multinomial) = x + (-A)
-(A::Multinomial, x::Number) = A + (-x)
*(x::Number, a::Monomial) = Monomial(deepcopy(a.exponent), x*a.coefficient)
*(a::Monomial, x::Number) = x*a
*(x::Number, A::Multinomial) = [Monomial(deepcopy(a.exponent), x*a.coefficient) for a in A]
*(A::Multinomial, x::Number) = x*A

^(s::Symbol, xp::Array{Int,1}) = Monomial(xp,1)

function deMo()
    # A has an int and a real coefficient
    # B has an int and an imaginary coefficient
    # Both A and B have constant terms with coefficient 1
    @show A = 1 + 3.4*:x^[1,2]
    println()
    @show B = 1 + 6im*:x^[2,1]
    println()
    @show A+B
    println()
    # A-B has a 0 term which is eliminated during term collection 
    @show A-B
    println()
    @show A*B
    nothing
end
    
            
