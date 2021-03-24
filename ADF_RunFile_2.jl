using CPLEX
using JuMP
using REoptLite
using CSV, DataFrames
using JSON

# City names
cities = ["Albuquerque", "Atlanta", "Baltimore", "Boulder", "Chicago", "Duluth",
"Helena", "Houston", "LosAngeles", "Miami", "Minneapolis", "Phoenix", "SanFrancisco", "Seattle"]

# Building types
building_types = ['hosp', 'school', 'warehouse']

function GenerateJSONs(; city::String)
    scenario_path = "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$city.json" #

  # Open city name json
  dict = Dict()
  open(scenario_path, "r") do f
      # global dict
      dict=JSON.parse(f)  # parse and transform data
  end

  # Update building-specific values for each building type
  hosp = deepcopy(dict)
  school = deepcopy(dict)
  warehouse = deepcopy(dict)

  # Available roof space
  hosp["Site"]["roof_squarefeet"] = 1000.0 #TODO
  school["Site"]["roof_squarefeet"] = 1000.0 #TODO
  warehouse["Site"]["roof_squarefeet"] = 1000.0 #TODO

  # DOE Reference Building name
  hosp["ElectricLoad"]["doe_reference_name"]= "Hospital"
  school["ElectricLoad"]["doe_reference_name"]= "SecondarySchool"
  warehouse["ElectricLoad"]["doe_reference_name"]= "Warehouse"

  # Critical load %
  hosp["ElectricLoad"]["critical_load_pct"] = 0.85
  school["ElectricLoad"]["critical_load_pct"] = 0.60
  warehouse["ElectricLoad"]["critical_load_pct"] = 0.10

  # Value of lost load
  hosp["Financial"]["VoLL"] = 140.0
  school["Financial"]["VoLL"] = 72.0
  warehouse["Financial"]["VoLL"] = 4.0

  # City and Building-specific inputs

  if city == "Albuquerque"
    # Outage start timesteps
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO

     # TODO:Maybe also:
     # monthly_energy_rates,
     # monthly_demand_rates,
     # NEM,
     # wholesale rate 
  elseif city == "Atlanta"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Baltimore"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Boulder"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Chicago"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Duluth"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Helena"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Houston"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "LosAngeles"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Miami"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Minneapolis"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Phoenix"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "SanFrancisco"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  elseif city == "Seattle"
      hosp["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      school["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
      warehouse["ElectricUtility"]["outage_start_timesteps"]= [] #TODO
  end

  # For each building type: Create bau & techs files (hosp, school, and warehouse are the "inv case" jsons)
  hosp_bau = create_BAU(hosp)
  school_bau = create_BAU(hosp)
  warehouse_bau = create_BAU(hosp)

  # For each bldg, for bau and techs cases, create objective scenarios

  # HOSPITAL
  hosp_b_bau = create_objs(hosp_bau)[1]
  hosp_br_bau = create_objs(hosp_bau)[2]
  hosp_brc_bau = create_objs(hosp_bau)[3]
  hosp_brch_bau = create_objs(hosp_bau)[4]

  hosp_b_techs = create_objs(hosp)[1]
  hosp_br_techs = create_objs(hosp)[2]
  hosp_brc_techs = create_objs(hosp)[3]
  hosp_brch_techs = create_objs(hosp)[4]

  # SECONDARY SCHOOL
  school_b_bau = create_objs(school_bau)[1]
  school_br_bau = create_objs(school_bau)[2]
  school_brc_bau = create_objs(school_bau)[3]
  school_brch_bau = create_objs(school_bau)[4]

  school_b_techs = create_objs(school)[1]
  school_br_techs = create_objs(school)[2]
  school_brc_techs = create_objs(school)[3]
  school_brch_techs = create_objs(school)[4]

  # WAREHOUSE
  warehouse_b_bau = create_objs(warehouse_bau)[1]
  warehouse_br_bau = create_objs(warehouse_bau)[2]
  warehouse_brc_bau = create_objs(warehouse_bau)[3]
  warehouse_brch_bau = create_objs(warehouse_bau)[4]

  warehouse_b_techs = create_objs(warehouse)[1]
  warehouse_br_techs = create_objs(warehouse)[2]
  warehouse_brc_techs = create_objs(warehouse)[3]
  warehouse_brch_techs = create_objs(warehouse)[4]

  # Write all dicts to json files
  list_scenarios = [
      # HOSPITAL
      hosp_b_bau,
      hosp_br_bau,
      hosp_brc_bau,
      hosp_brch_bau,

      hosp_b_techs,
      hosp_br_techs,
      hosp_brc_techs,
      hosp_brch_techs,
      "
      # SECONDARY SCHOOL
      school_b_bau,
      school_br_bau,
      school_brc_bau,
      school_brch_bau,

      school_b_techs,
      school_br_techs,
      school_brc_techs,
      school_brch_techs,

      # WAREHOUSE
      warehouse_b_bau,
      warehouse_br_bau,
      warehouse_brc_bau,
      warehouse_brch_bau,

      warehouse_b_techs,
      warehouse_br_techs,
      warehouse_brc_techs,
      warehouse_brch_techs "
  ]

  # **Write each to json**
  for scen in list_scenarios
      open("/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$scen.json", "w") do f
              write(f, JSON.json(scen), 4)
            end
        end


  # Functions
  function create_BAU(dict)
    BAU = deepcopy(dict)

    BAU["PV"]["max_kw"] = 0.0
    BAU["Storage"]["max_kw"] = 0.0
    BAU["Storage"]["max_kwh"] = 0.0

    return BAU
  end

  function create_objs(dict)
    b = deepcopy(dict) # obj: min cap + O&M + energy bill
    br = deepcopy(dict) # obj: min cap + O&M + energy bill + resilience
    brc = deepcopy(dict) # obj: min cap + O&M + energy bill + resilience + climate
    brch = deepcopy(dict) # obj: min cap + O&M + energy bill + resilience + climate + health

    b["Financial"]["include_climate_in_obj"] = false
    b["Financial"]["include_health_in_obj"] = false
    b["Financial"]["include_resilience_in_obj"] = false

    br["Financial"]["include_climate_in_obj"] = false
    br["Financial"]["include_health_in_obj"] = false
    br["Financial"]["include_resilience_in_obj"] = true

    brc["Financial"]["include_climate_in_obj"] = true
    brc["Financial"]["include_health_in_obj"] = false
    brc["Financial"]["include_resilience_in_obj"] = true

    brch["Financial"]["include_climate_in_obj"] = true
    brch["Financial"]["include_health_in_obj"] = true
    brch["Financial"]["include_resilience_in_obj"] = true

    return b, br, brc, brch

  end

end

# Generate JSONS
GenerateJSONs(city)

# Function Run analysis(city)
# For each bldg type:
  # For each b, br, brc, brch:
    # Run bau & techs file
    # Save results to csv with name: City_Bldgtype_b(dbr,brc,brch)_base

# Scenario file names for BAU and comparison case
bau_file = "aa_LargeOffice_b_bau"
techs_file = "aa_LargeOffice_b_techs"

# Name of saved file
savename = bau_file[1:end-4] # "aa_LargeOffice_brhc_24hr_VoLL100_CLP20_grid_can_charge"

# Run optimizations (BAU and Investment Case)
m = Model(CPLEX.Optimizer)
results_bau = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/aa_dc/$bau_file.json")

m = Model(CPLEX.Optimizer)
results_techs = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/aa_dc/$techs_file.json")

# Save results to csv
savelist = [
  ## Select inputs
  "cost_ton_CO2",
  "cost_ton_NOx",
  "cost_ton_SO2",
  "outage_durations",
  # "outage_probabilities",
  #"outage_start_timesteps",
  "dvUnservedLoad",

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

# Write battery SOC to csv
"""
