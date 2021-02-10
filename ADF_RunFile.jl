using CPLEX
using JuMP
# using Revise
using REoptLite
using CSV, DataFrames

# Scenario file names for BAU and comparison case
bau_file = "aa_MidriseApartment_bhc_bau"
techs_file = "aa_MidriseApartment_bhc_techs"

# Name of saved file
savename = bau_file[1:end-4]

# Run optimizations
m = Model(CPLEX.Optimizer)
results_bau = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$bau_file.json")
m = Model(CPLEX.Optimizer)
results_techs = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$techs_file.json")

# Save results to csv
savelist = [
  ## Select inputs
  "cost_ton_CO2",
  "cost_ton_NOx",
  "cost_ton_SO2",
  #"outage_durations",
  #"outage_probabilities",
  #"outage_start_timesteps",

  ## System sizes
  "PV_kw", "batt_kw", "batt_kwh",

  ## LCC and sub-components
  "lcc",
  "net_capital_costs_plus_om",
  # "gen_total_fuel_cost",
  "total_energy_cost",
  "total_demand_cost",
  "total_fixed_cost",
  "total_min_charge_adder",
  "total_export_benefit",
  "TotalCO2Cost",
  "TotalHealthCost",
  ## Outage-related costs in the objective
  #"expected_outage_cost",
  #"mgTotalTechUpgradeCost",
  #"dvMGStorageUpgradeCost",
  #"ExpectedMGFuelCost"
  ]

# Save results in dataframe
d = Dict("vars"=>[key for key in savelist],
      "bau"=>[results_bau[key] for key in savelist],
      "techs"=>[results_techs[key] for key in savelist]
)
df = DataFrame(d)

# Create NPV column (for lcc costs)
df[!,"npv"] = df[!,"bau"] - df[!,"techs"]

# Write results to csv
CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/NREL_Pres/$savename.csv", df)
