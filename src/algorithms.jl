
function S_poly(A::Multinomial, B::Multinomial)
    x = A[end].indeterminate
    tmp = [max(A[end].exponent[i], B[end].exponent[i]) for i in 1:x.degree]
    return B[end].coefficient*x^(tmp-A[end].exponent)*A -
        A[end].coefficient*x^(tmp-B[end].exponent)*B
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
