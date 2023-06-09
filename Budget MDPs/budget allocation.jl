using JuMP
using Gurobi

"""
Solve useful budget assignment problem (UBAP).
"""
function solve_UBAP(num_subs::Int, init_state_subs::Vector{T}, global_budget::W, B_vec_subs::Vector{Vector{Vector{Vector{Float64}}}}, v_vec_subs::Vector{Vector{Vector{Vector{Float64}}}}; relax::Bool=false) where {T, W <: Real}
    M = [i for i in 1:num_subs]
    L = [1:length(B_vec_subs[i][1][init_state_subs[i]]) for i = 1:num_subs]
    # L = [collect(1:length(BB_vec_subs[i][1][init_state_subs[i]])) for i = 1:num_subs]
    # @variable(model, x[i in 1:num_subs, k in 1:length(BB_vec_subs[i][1][init_state_subs[i]])], Bin)

    model = Model(Gurobi.Optimizer)
    @variable(model, x[i in M, k in L[i]], Bin)

    @constraint(model, sum([sum([B_vec_subs[i][1][init_state_subs[i]][k] * x[i,k] for k in L[i]]) for i in M]) <= global_budget)
    @constraint(model, [i in M] , sum([x[i,k] for k in L[i]]) == 1)

    @objective(model, Max, sum([sum([v_vec_subs[i][1][init_state_subs[i]][k] * x[i,k] for k in L[i]]) for i in M]))

    if relax
        relax_integrality(model)
    end
    # println("$model")

    optimize!(model)
    @show value.(x)

    return objective_value(model)
    # return model
end


"""
Solve useful budget assignment problem (UBAP).
"""
function solve_BAP(num_subs::Int, init_state_subs::Vector{T}, global_budget::W, B_vec_subs::Vector{Vector{Vector{Vector{Float64}}}}, v_vec_subs::Vector{Vector{Vector{Vector{Float64}}}}) where {T, W <: Real}
    
    return solve_UBAP(num_subs, init_state_subs, global_budget, B_vec_subs, v_vec_subs, relax=true)
end


"""
Given solution from JuMP model, extract the indices of the assigned budgets for each state.
"""
function extract_budget_index_UBAP(x_vals, num_subs::Int)
    indices = Vector{Int}(undef, num_subs)
    for i in 1:num_subs
        for k in eachindex(x_vals[i,:])
            if x_vals[i,k[1]] > 0.5
                indices[i] = k[1]   # k is a one-element tuple
                break
            end
        end
    end
    return indices
end


function extract_budget_index_BAP(x_vals, num_subs::Int)
    
end