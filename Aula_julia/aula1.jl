

# arithmetic
1 + 1
2 - 1
2 * 3
4 / 2
5 / 2
2^3
5 % 2
1 + (2 * 3)^4 * 5


# boolean
3 < 2
3 >= 3
4 == 2 * 2
2 * 2 != 4
true && false
true || false
false + true

(Int128(2)^64)
(Int128(2)^64)/2

2^16

bitstring(Int8(800))
bitstring(Int128(35555))
bitstring(Int64(3))
bitstring(Int8(-4))

bitstring(Int64(18446744073709551614))
bitstring(UInt64(18446744073709551614))


N::Int16

x = 2.5

# variable
x = 1
y = 2
z = x + y
x
y
z
x = 2
x
y
z
z = x + y
z


const d = 4

const d = 40

const d = 40.0



#variable part 2
i = 1
i = i + 1
i += 1
# i++ does not work in Julia


# number
typeof(-3)
typeof(1.2)
0.1 + 0.2 == 0.3

0.1 + 0.2 >= 0.3-0.0001 && 0.1 + 0.2 <= 0.3+0.0001

typeof(pi)

1000000 == 1_000_000

sqrt(4)
round(3.14159, digits = 2)

## ----------------------------------------


N = 13


#! SOLUCAO RUIM

function roda_aleatorio(N::Int64)
        
    V = []

    for i in 1:N
        append!(V, rand(1:10))
    end

    return V
end


#? SOLUCAO BOA

function roda_aleatorio_2(N::Int64)
        
    V = zeros(Int, N)

    for i in 1:N
        V[i] = rand(1:10)
    end
    return V
end

@time roda_aleatorio(100_000_000)
@time roda_aleatorio_2(100_000_000)


## --------------------------------------------
using Plots
using StatsBase

V = rand(1:10, 10)

mean(V)


# dictionary part 1
dog = Dict(
    "name" => "eggdog",
    "age" => 2,
    "breed" => "egg-dog mix"
)
dog["name"]
dog["age"]


# struct
mutable struct Dog
    name::String
    age::Integer
    breed::String
end
dog1 = Dog("eggdog", 2, "egg-dog mix")
dog1.name
dog1.name = "Doggo"


cachorros = Array{Dog}


# ----------------------

x = 3
y = 2
if x > y
    println("$x is greater than $y")
elseif x < y
    println("$x is less than $y")
else
    println("$x is equal to $y")
end

# ----------------------------------------
#? métodos de funções

function my_add(x::Int64, y::Int64)
    println("A soma dos números inteiros é:", x + y)
end

function my_add(x::Float64, y::Float64)
    println("A soma dos números reais é:", x + y)
end


function my_add(x, y)
    println("A soma dos números quaiquer é:", x + y)
end

my_add(1, 2)
my_add(1.0, 2.0)
my_add(1.0, 2)


## ------------------------------------

#? O julia aceita Unicode
λ = 2
μ = 6

μ+λ

1 ∈ [1,2,3,4]

π


## ------------------------------------
using RDatasets
using Plots

iris = dataset("datasets", "iris")

names(iris)


Plots.scatter(
    [iris.SepalLength iris.PetalLength],
    [iris.SepalWidth iris.PetalWidth],
    labels = ["Sepal" "Petal"],
    xlabel = "Length", ylabel = "Width"
)


scatter!(iris.SepalLength, iris.PetalWidth, label = "Sepal L vs Petal W")
scatter!(iris.PetalLength, iris.SepalWidth, label = "Petal L vs Sepal W")

## ------------------------------

using StatsPlots
using DataFrames

teste = :teste
typeof(teste)

iris[:, :SepalLength]

@df iris scatter(:SepalWidth, [:PetalWidth, :PetalLength],
    labels = ["Petal width" "Petal length"],
    mc = [:purple :blue]
)


@df iris scatter(:SepalWidth, :PetalWidth,
    marker_z = :SepalLength,
    labels = [nothing "Sepal Length"],
    color = :jet,
    colorbar_title = "Sepal Length",
    xlabel = "Sepal Width", ylabel = "Petal Width"
)

## -----------------------------------------


f(x) = 2*x
g(x) = x^2


plot([f, g])


v = [1, 2, 3]

v .+ 1 

(v .+ 1) .* 2
@. (v + 1) * 2

f(3)
g(3)

f(v)
g(v)
g.(v)



## ---------------------------------------

N = 1000 # numero de pontos


function calculate_pi(N)
    r = 1
    x = -r .+ (2*r) .* rand(N)
    y = -r .+ (2*r) .* rand(N)
    
    result = x.^2 .+ y.^2 .< r
    
    π = 4*sum(result)/length(result)
    π
end


calculate_pi(100000000)

calculate_pi(100000000)
calculate_pi(10000000)


## ---------------------------------------



## paralelizando
function run_sim()
    r = 1
    x = -r .+ (2*r) .* rand()
    y = -r .+ (2*r) .* rand()
    
    result = x^2 + y^2 < r
    result
end


N = 100_000

@time teste = map(x-> run_sim(), 1:N)
4*sum(teste)/length(teste)


## -----------------------------------

using Distributed

nprocs()
addprocs(4)

@time teste = pmap(x -> run_sim(), 1:N)
4*sum(teste)/length(teste)

# precisa adicionar em todos os processadores
@everywhere function run_sim()
    r = 1
    x = -r .+ (2*r) .* rand()
    y = -r .+ (2*r) .* rand()
    
    result = x^2 + y^2 < r
    result
end



@everywhere function random_numbers(N)
    r = 1
    x = -r .+ (2*r) .* rand(N)
    y = -r .+ (2*r) .* rand(N)
    
    result = x.^2 .+ y.^2 .< r
    
    return result
end



N1 = Int(N/(nprocs()-1))

repeat([N1], 4)

@time result = pmap(k-> random_numbers(k), repeat([N1], 4))


## ---------------------------------------------


using Plots, DifferentialEquations


# f(u,t,p) = du/dt = u

f(u, p, t) = u

# definindo o problema

u0 = [2.0]
tspan = [0, 10]
prob = ODEProblem(f, u0, tspan)

# resolvendo o problema
sol = solve(prob, Tsit5())

sol.u

plot(sol)



# mudando parametros


f(u, p, t) = p[1]*u

u0 = [2.0]
tspan = [0, 10]
p = [2.0]
prob = ODEProblem(f, u0, tspan, p)


# resolvendo o problema
sol = solve(prob, Tsit5())
plot!(sol)


### Sistema de equações diferenciais

function f!(du, u, p, t)
    # Lotka-Volterra --> presa predador
    du[1] = p[1]*u[1] - p[2]*u[1]*u[2] # dx/dt = αx-βxy
    du[2] = p[3]*u[1]*u[2] - p[4]*u[2] # dy/dt = δxy-μy
    return du
end


u0 = [2.0, 4.0]
tspan = [0, 10]
p = [10.0, 2.0, 1.5, 5.0]

prob = ODEProblem(f!, u0, tspan, p)

sol = solve(prob,Tsit5())

plot(sol)




sol = solve(prob,Tsit5(), saveat = 0.01)
solucao = Matrix(hcat(sol.u...)')

plot(sol.t, solucao)

plot(solucao[:, 1], solucao[:, 2])



u0 = [2.0, 4.0]
tspan = [0, 100]
p = [10.0, 2.0, 1.5, 5.0]

prob = ODEProblem(f!, u0, tspan, p)

sol = solve(prob,Tsit5())

plot(sol, vars = (1,2))


u0 = [2.0001, 4.0]
tspan = [0, 100]
p = [10.0, 2.0, 1.5, 5.0]

prob = ODEProblem(f!, u0, tspan, p)

sol = solve(prob,Tsit5())

plot!(sol, vars = (1,2))


#? Brincadeira

function lorenz!(du,u,p,t)
    du[1] = 10.0(u[2]-u[1])
    du[2] = u[1]*(28.0-u[3]) - u[2]
    du[3] = u[1]*u[2] - (8/3)*u[3]
end


   u0 = [1.0;0.0;0.0]
   tspan = (0.0,100.0)
   prob = ODEProblem(lorenz!,u0,tspan)
   
   # Test that it worked
#    using OrdinaryDiffEq
    sol = solve(prob,Tsit5())
    plot(sol,vars=(1,2,3))


   
   u0 = [1.0002;0.0;0.0]
   tspan = (0.0,100.0)
   prob = ODEProblem(lorenz!,u0,tspan)
   
   # Test that it worked
#    using OrdinaryDiffEq
   sol = solve(prob,Tsit5())
   plot!(sol,vars=(1,2,3))

   ###############################



## ------------------------------

   
function check(x, v)
    x ∈ v
end

x = 2

v = rand(1:10000, 100000000);

@time check(23, v)
