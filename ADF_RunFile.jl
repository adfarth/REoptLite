test

using CPLEX
using JuMP
# using Revise
using REoptLite

m = Model(CPLEX.Optimizer)
results = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/outage_AA_ADF.json")


# push!(LOAD_PATH,"/Users/amandafarthing1/Google Drive File Stream/My Drive/0_Michigan/Master's Thesis/REoptLite/src")
# using REoptLite
# results2 = run_reopt(m, "/Users/amandafarthing1/Google Drive File Stream/My Drive/0_Michigan/Master's Thesis/REoptLite/test/scenarios/outage_ADF.json")
