using CPLEX
using JuMP
# using Revise
using REoptLite
using CSV, DataFrames

# Scenario file names for BAU and comparison case
bau_file = "aa_LargeOffice_brhc_bau"
techs_file = "aa_LargeOffice_brhc_techs"

# Name of saved file
savename = bau_file[1:end-4] # "aa_LargeOffice_brhc_24hr_VoLL100_CLP20_grid_can_charge"

# Run optimizations (BAU and Investment Case)
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
  # "outage_durations",
  # "outage_probabilities",
  #"outage_start_timesteps",
  #"dvUnservedLoad",

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
  "expected_outage_cost",
  "mgTotalTechUpgradeCost",
  "dvMGStorageUpgradeCost",
  # "ExpectedMGFuelCost"
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
CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/USA/$savename.csv", df) # $savename (file name)

"""
# Write net_load in bau and techs case to csv
d2 = Dict("net_load_bau"=>results_bau["net_load"],
          "net_load_techs"=>results_techs["net_load"]
)
df2 = DataFrame(d2)

# Write results to csv
CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/Sensitivity_2020_2050_mers/$savename net_load.csv", df2) # $savename (file name)
"""
