using JuMP, GLPKMathProgInterface, Distances

file_name = "tsp_25_1"
f = open("./data/" * file_name);
lines = readlines(f)
N = length(lines)
println("N: ", N)

c_pos = [Vector{Float64}(2) for _ in 1:N]

for i = 1:N
    x_str, y_str = split(lines[i])
    c_pos[i] = [parse(Float64, x_str), parse(Float64, y_str)]
end

function solved(m)
    x_val = getvalue(x)
    
    # find cycle
    cycle_idx = Array{Int}(0)
    push!(cycle_idx, 1)
    while true
        v, idx = findmax(x_val[f=cycle_idx[end],t=1:N])
        if idx == cycle_idx[1]
            break
        else
            push!(cycle_idx,idx)
        end
    end
    println("cycle_idx: ", cycle_idx)
    println("Length: ", length(cycle_idx))
    if length(cycle_idx) < N
        @constraint(m, sum(x[f=cycle_idx,t=cycle_idx]) <= length(cycle_idx)-1)
        return false
    end
    return true
end 

m = Model(solver=GLPKSolverMIP())
@variable(m, x[f=1:N,t=1:N], Bin)
@objective(m, Min, sum(x[f=i,t=j]*euclidean(c_pos[i],c_pos[j]) for i=1:N,j=1:N))
@constraint(m, notself[i=1:N], x[f=i,t=i] == 0)
@constraint(m, oneout[i=1:N], sum(x[f=i,t=1:N]) == 1)
@constraint(m, onein[j=1:N], sum(x[f=1:N,t=j]) == 1)
for f=1:N, t=1:N
    @constraint(m, x[f,t]+x[t,f] <= 1)
end

status = solve(m)

while !solved(m)
    status = solve(m)
end

println("Obj: ", getobjectivevalue(m))
# println("Cus to Fac: ",getvalue(cf))

if status == :Optimal
    optimal = 1
else
    optimal = 0
end
open("./sol/" * file_name, "w") do file
    write(file, string(getobjectivevalue(m)) * " " * string(optimal) * "\n")
    to_vec = Vector{String}(N)
    x_vals = getvalue(x)
    for j in 1:N
        v,idx = findmax(x_vals[f=j,t=1:N])
        to_vec[j] = string(idx)
    end
    write(file, join(to_vec, " "))
end