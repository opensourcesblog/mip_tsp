using JuMP, GLPK, Distances

function is_tsp_solved(m, x; benchmark=false)
    N = size(x)[1]
    x_val = JuMP.value.(x)
    
    # find cycle
    cycle_idx = Int[]
    push!(cycle_idx, 1)
    while true
        v, idx = findmax(x_val[cycle_idx[end],1:N])
        if idx == cycle_idx[1]
            break
        else
            push!(cycle_idx,idx)
        end
    end
    if !benchmark
        println("cycle_idx: ", cycle_idx)
        println("Length: ", length(cycle_idx))
    end
    if length(cycle_idx) < N
        @constraint(m, sum(x[cycle_idx,cycle_idx]) <= length(cycle_idx)-1)
        return false
    end
    return true
end 

function solve_tsp(;file_name="tsp_25_1", benchmark=false)
    f = open("./data/" * file_name);
    lines = readlines(f)
    N = length(lines)
    !benchmark && println("N: ", N)

    c_pos = [Vector{Float64}(undef, 2) for _ in 1:N]

    for i = 1:N
        x_str, y_str = split(lines[i])
        c_pos[i] = [parse(Float64, x_str), parse(Float64, y_str)]
    end

    m = Model(with_optimizer(GLPK.Optimizer))
    dist_mat = zeros(N,N)
    for i=1:N, j=i+1:N
        d = euclidean(c_pos[i],c_pos[j])
        dist_mat[i,j] = d
        dist_mat[j,i] = d
    end
    @variable(m, x[1:N,1:N], Bin)
    @objective(m, Min, sum(x[i,j]*dist_mat[i,j] for i=1:N,j=1:N))
    for i=1:N 
        @constraint(m, x[i,i] == 0)
        @constraint(m, sum(x[i,1:N]) == 1)
    end
    for j=1:N
        @constraint(m, sum(x[1:N,j]) == 1)
    end
    for f=1:N, t=1:N
        @constraint(m, x[f,t]+x[t,f] <= 1)
    end

    optimize!(m)
    !benchmark && println("Obj: ", JuMP.objective_value(m))

    while !is_tsp_solved(m, x; benchmark=benchmark)
        optimize!(m)
    end

    !benchmark && println("Obj: ", JuMP.objective_value(m))

    if JuMP.termination_status(m) == MOI.OPTIMAL
        optimal = 1
    else
        optimal = 0
    end
    if !benchmark
        open("./sol/" * file_name, "w") do file
            write(file, string(JuMP.objective_value(m)) * " " * string(optimal) * "\n")
            to_vec = Vector{String}(undef,N)
            x_vals = JuMP.value.(x)
            for j in 1:N
                v,idx = findmax(x_vals[j,1:N])
                to_vec[j] = string(idx)
            end

            write(file, join(to_vec, " "))
        end
    end
end