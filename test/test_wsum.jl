# Test weighted sum 

using NumericExtensions
using Base.Test

xi = rand(1:100, 6)
x = rand(6)
y = rand(6)
z = rand(6)
w = rand(6)

# full reduction

@test_approx_eq wsum(w, xi) sum(w .* xi)
@test_approx_eq wsum(w, x) sum(w .* x)
@test_approx_eq wsum(w, Abs2(), x) sum(w .* abs2(x))
@test_approx_eq wsum(w, Multiply(), x, y) sum(w .* (x .* y))
@test_approx_eq wsum(w, FMA(), x, y, z) sum(w .* (x + y .* z))
@test_approx_eq wsum_fdiff(w, Abs2(), x, y) sum(w .* abs2(x - y))

# partial reduction on matrices

xi = rand(1:100, 5, 6)
x = rand(5, 6)
y = rand(5, 6)
w1 = rand(5)
w2 = rand(1, 6)

@test_approx_eq wsum(w1, xi, 1) sum(w1 .* xi, 1)
@test_approx_eq wsum(w2, xi, 2) sum(w2 .* xi, 2)

@test_approx_eq wsum(w1, x, 1) sum(w1 .* x, 1)
@test_approx_eq wsum(w2, x, 2) sum(w2 .* x, 2)

@test_approx_eq wsum(w1, Abs2(), x, 1) sum(w1 .* abs2(x), 1)
@test_approx_eq wsum(w2, Abs2(), x, 2) sum(w2 .* abs2(x), 2)

@test_approx_eq wsum(w1, Multiply(), x, y, 1) sum(w1 .* (x .* y), 1)
@test_approx_eq wsum(w2, Multiply(), x, y, 2) sum(w2 .* (x .* y), 2)

@test_approx_eq wsum_fdiff(w1, Abs2(), x, y, 1) sum(w1 .* abs2(x - y), 1)
@test_approx_eq wsum_fdiff(w2, Abs2(), x, y, 2) sum(w2 .* abs2(x - y), 2)

# partial reduction on cubes

xi = rand(1:100, 5, 6, 3)
x = rand(5, 6, 3)
y = rand(5, 6, 3)
w1 = rand(5)
w2 = rand(1, 6)
w3 = rand(1, 1, 3)

@test_approx_eq wsum(w1, xi, 1) sum(w1 .* xi, 1)
@test_approx_eq wsum(w2, xi, 2) sum(w2 .* xi, 2)
@test_approx_eq wsum(w3, xi, 3) sum(w3 .* xi, 3)

@test_approx_eq wsum(w1, x, 1) sum(w1 .* x, 1)
@test_approx_eq wsum(w2, x, 2) sum(w2 .* x, 2)
@test_approx_eq wsum(w3, x, 3) sum(w3 .* x, 3)

@test_approx_eq wsum(w1, Abs2(), x, 1) sum(w1 .* abs2(x), 1)
@test_approx_eq wsum(w2, Abs2(), x, 2) sum(w2 .* abs2(x), 2)
@test_approx_eq wsum(w3, Abs2(), x, 3) sum(w3 .* abs2(x), 3)

@test_approx_eq wsum(w1, Multiply(), x, y, 1) sum(w1 .* (x .* y), 1)
@test_approx_eq wsum(w2, Multiply(), x, y, 2) sum(w2 .* (x .* y), 2)
@test_approx_eq wsum(w3, Multiply(), x, y, 3) sum(w3 .* (x .* y), 3)

@test_approx_eq wsum_fdiff(w1, Abs2(), x, y, 1) sum(w1 .* abs2(x - y), 1)
@test_approx_eq wsum_fdiff(w2, Abs2(), x, y, 2) sum(w2 .* abs2(x - y), 2)
@test_approx_eq wsum_fdiff(w3, Abs2(), x, y, 3) sum(w3 .* abs2(x - y), 3)


# convenience functions

x = randn(6)
y = rand(6)
w = rand(6)

@test_approx_eq wasum(w, x) sum(w .* abs(x))
@test_approx_eq wadiffsum(w, x, y) sum(w .* abs(x - y))
@test_approx_eq wadiffsum(w, x, 1) sum(w .* abs(x - 1))

@test_approx_eq wsqsum(w, x) sum(w .* abs2(x))
@test_approx_eq wsqdiffsum(w, x, y) sum(w .* abs2(x - y))
@test_approx_eq wsqdiffsum(w, x, 1) sum(w .* abs2(x - 1))

x = randn(5, 6)
y = rand(5, 6)
w1 = rand(5)
w2 = rand(1, 6)

@test_approx_eq wasum(w1, x, 1) sum(w1 .* abs(x), 1)
@test_approx_eq wasum(w2, x, 2) sum(w2 .* abs(x), 2)

r = zeros(6); wasum!(r, w1, x, 1) 
@test_approx_eq r vec(wasum(w1, x, 1))
r = zeros(5); wasum!(r, w2, x, 2) 
@test_approx_eq r vec(wasum(w2, x, 2))

@test_approx_eq wadiffsum(w1, x, y, 1) sum(w1 .* abs(x - y), 1)
@test_approx_eq wadiffsum(w2, x, y, 2) sum(w2 .* abs(x - y), 2)

r = zeros(6); wadiffsum!(r, w1, x, y, 1) 
@test_approx_eq r vec(wadiffsum(w1, x, y, 1))
r = zeros(5); wadiffsum!(r, w2, x, y, 2) 
@test_approx_eq r vec(wadiffsum(w2, x, y, 2))

@test_approx_eq wsqsum(w1, x, 1) sum(w1 .* abs2(x), 1)
@test_approx_eq wsqsum(w2, x, 2) sum(w2 .* abs2(x), 2)

r = zeros(6); wsqsum!(r, w1, x, 1) 
@test_approx_eq r vec(wsqsum(w1, x, 1))
r = zeros(5); wsqsum!(r, w2, x, 2) 
@test_approx_eq r vec(wsqsum(w2, x, 2))

@test_approx_eq wsqdiffsum(w1, x, y, 1) sum(w1 .* abs2(x - y), 1)
@test_approx_eq wsqdiffsum(w2, x, y, 2) sum(w2 .* abs2(x - y), 2)

r = zeros(6); wsqdiffsum!(r, w1, x, y, 1) 
@test_approx_eq r vec(wsqdiffsum(w1, x, y, 1))
r = zeros(5); wsqdiffsum!(r, w2, x, y, 2) 
@test_approx_eq r vec(wsqdiffsum(w2, x, y, 2))




