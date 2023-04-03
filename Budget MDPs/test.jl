using LinearAlgebra
using JuMP
using Gurobi
import Random
using Pipe
include("./generate_data.jl")
include("./solve.jl")
include("./plotting.jl")

num_sub = 1   # number of classes of subprocesses
B_max = 10   # max budget at any state; TODO: should not be synonymous with global budget
T = 3    # time horizon ≈ 6 weeks of treatment

num_states = 3   # will assume all subMDPs have same number of states
states = [i for i = 1:num_states]

num_actions = 2   # will assume all subMDPs have same number of actions
actions = [i for i = 1:num_actions]

# Variables to hold state and action 
# s = zeros(Int, M)   # hold state of system
# a = zeros(Int, M)   # hold action taken by system

# Initial state distribution
# Random.seed!(1)
# α = rand(num_states)
# α = α ./ sum(α)
# # sum(α)

# Create P, utilities, costs, rewards
P, C, U, R = generate_data_rand(num_sub, num_states, num_actions);
# U_terminal = create_u(num_states, num_actions, seed = seed)
U_terminal = zeros(num_states)  # reward when no action is taken (e.g., at end of planning horizon); might not be used

# Discount factor
Random.seed!(1)
Γ = 1 .- rand(num_sub)*0.05

###############################################################################
# Run tests
sub = 1
B_union_vec, BB_vec, B_tilde_union_vec, v_union_vec, vv_vec, v_tilde_union_vec, B_vec, B_tilde_vec, v_vec, v_tilde_vec = compute_useful_budgets(states, actions, B_max, P[sub], C[sub], R[sub], Γ[sub], T);

t = 3
state = 1
action = 2
for t = 1:T
    println("B_union (t=$t) = $(B_union_vec[t][state])\n")
    println("v_union (t=$t) = $(v_union_vec[t][state])\n")
    # println("B (t=$t) = $(B_vec[t][state])\n")
    # println("v (t=$t) = $(v_vec[t][state])\n")
    # if t == T
    #     println("B (t=$(t+1)) = $(B_vec[t+1][state])\n")
    #     println("v (t=$(t+1)) = $(v_vec[t+1][state])\n")
    # end
end

for t in 1:T, i in 1:num_states
    plot_V(i, t, BB_vec[t][i], vv_vec[t][i], save_plot=false)
end

length(B_union_vec)
length(BB_vec)
length(B_tilde_union_vec)

length(B_tilde_vec)
length(B_vec)

length(v_union_vec)
length(vv_vec)
length(v_tilde_union_vec)

length(v_tilde_vec)
length(v_vec)

t = 3
state = 1
action = 2

B_union_vec[end][state]
B_vec[end][state, action]
B_tilde_union_vec[1][state]

v_union_vec[end][state]
v_vec[end][state, action]
v_tilde_union_vec[end][state]

plot_V(state, t, B_union_vec[t][state], v_union_vec[t][state])