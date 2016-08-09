#=

Data structures for exponents and polynomials. Orderings. Arithmetic operations. All experimental. 

For the moment, lex order is assumed and almost enforced.

=#

import Base.+, Base.*, Base.-, Base.^, Base.repr

immutable Indeterminate
    degree::Int
    Indeterminate(degree::Int) = degree > 0 ? new(degree) :
        error("Degree must be > 0")
end

type Monomial
    indeterminate::Indeterminate
    exponent::Array{Int,1}
    coefficient::Number

    function Monomial(x::Indeterminate)
        new(x, fill(1,x.degree), 1)
    end

    function Monomial(x::Indeterminate, c::Number)
        new(x, fill(1, x.degree), c)
    end

    function Monomial(x::Indeterminate, ex::Array{Int,1})
        Monomial(x, ex, 1)
    end

    function Monomial(x::Indeterminate, ex::Array{Int,1}, c::Number)
        length(ex) == x.degree || error("Length of exponent, $ex, must match degree of indeterminate, $x.degree")
        new(x,ex,c)
    end
    
end

typealias Multinomial Array{Monomial,1}

function repr(x::Monomial)
    ex = x.exponent
    c = x.coefficient
    "$c*x^$ex"
end

function repr(A::Multinomial)
    str = ""
    for a in A
        str = string(str, " + ",repr(a))
    end
    str              
end

function ltlex(a::Monomial, b::Monomial)
    b.indeterminate == a.indeterminate || error("Monomials $a and $b have different indeterminates.")
    return lexcmp(b.exponent,a.exponent) == 1
end

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
    if na==0 || nb==0 return Array(Monomial,0) end
    x = A[1].indeterminate
    C = Array(Monomial, na*nb)
    for i in 1:na
        Ae = A[i].exponent
        Ac = A[i].coefficient
        offset = (i-1)*nb
        for j in 1:nb
            C[j+offset] = Monomial(x, Ae+B[j].exponent, Ac*B[j].coefficient)
        end
    end
    n = collect_terms!(C)
    return C[1:n]
end

# syntactic sugar

function -(a::Monomial)  Monomial(a.indeterminate, a.exponent, -a.coefficient) end

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
-(A::Multinomial, B::Monomial) = A - [B]
-(A::Monomial, B::Monomial)    = [A] - [B]
*(A::Monomial, B::Multinomial) = [A]*B
*(A::Multinomial, B::Monomial) = A*[B]
*(A::Monomial, B::Monomial)    = [A]*[B]

+(x::Number, a::Monomial) = Monomial(a.indeterminate,
                                     zeros(Int,length(a.exponent)), x) + a
+(a::Monomial, x::Number) = x+a
+(x::Number, A::Multinomial) = Monomial(A[1].indeterminate,
                                        zeros(Int,length(A[1].exponent)), x)+A
+(A::Multinomial, x::Number) = x + A
-(x::Number, a::Monomial) = (-a)+x
-(a::Monomial, x::Number) = a+(-x)
-(x::Number, A::Multinomial) = x + (-A)
-(A::Multinomial, x::Number) = A + (-x)
*(x::Number, a::Monomial) = Monomial(a.indeterminate,
                                     deepcopy(a.exponent), x*a.coefficient)
*(a::Monomial, x::Number) = x*a
*(x::Number, A::Multinomial) = [Monomial(a.indeterminate,
                                         deepcopy(a.exponent),
                                         x*a.coefficient) for a in A]
*(A::Multinomial, x::Number) = x*A

^(s::Indeterminate, xp::Array{Int,1}) = Monomial(s,xp,1)

function demo_arithmetic()
    @show x = Indeterminate(2)
    println()
    # A has an int and a real coefficient
    # B has an int and an imaginary coefficient
    # Both A and B have constant terms with coefficient 1
    @show A = 1 + 3.4*x^[1,2]
    println()
    @show B = 1 + 6im*x^[2,1]
    println()
    @show A+B
    println()
    # A-B has a 0 term which is eliminated during term collection 
    @show A-B
    println()
    @show A*B
    nothing
end
