using CPLEX
using JuMP
using REoptLite
using CSV, DataFrames
using JSON

# To evalute hour that results in max unserved load for a subset of cities
# Allowing solar and storage to optimally size
# VoLL = $300 and resilience is valued to make sure we can see effect of microgrid dispatch

# City name
cities = ["Albuquerque", "Atlanta", "Chicago", "Seattle"]

for i in (1:length(cities))
  c = cities[i]

  city = "$c"*"_outage"

  scenario_path = "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$city/$city.json"

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

  hosp["ElectricLoad"]["doe_reference_name"]= "Hospital"
  school["ElectricLoad"]["doe_reference_name"]= "SecondarySchool"
  warehouse["ElectricLoad"]["doe_reference_name"]= "Warehouse"

  hosp["ElectricLoad"]["critical_load_pct"] = 0.85
  school["ElectricLoad"]["critical_load_pct"] = 0.60
  warehouse["ElectricLoad"]["critical_load_pct"] = 0.10

  # Functions
"""
  function create_BAU(dict)
    BAU = deepcopy(dict)

    BAU["PV"]["max_kw"] = 0.0
    BAU["Storage"]["max_kw"] = 0.0
    BAU["Storage"]["max_kwh"] = 0.0

    return BAU
  end
"""

  function create_objs(dict)
    b = deepcopy(dict) # obj: min cap + O&M + energy bill

    b["Financial"]["include_climate_in_obj"] = false
    b["Financial"]["include_health_in_obj"] = false
    b["Financial"]["include_resilience_in_obj"] = true # to see how dvUnservedLoad changes

    return b

  end

  # NOT running BAU case
  # For each building type: Create bau & techs files (hosp, school, and warehouse are the "inv case" jsons)
  #hosp_bau = create_BAU(hosp)
  #school_bau = create_BAU(school)
  #warehouse_bau = create_BAU(warehouse)

  # For each bldg, create objective scenarios
  hosp_b_techs = create_objs(hosp)
  school_b_techs = create_objs(school)
  warehouse_b_techs = create_objs(warehouse)

  # Write all dicts to json files
  list_scenarios = [hosp_b_techs, school_b_techs, warehouse_b_techs]

  namez = ["hosp_techs", "school_techs", "warehouse_techs"]

  # Write each to json
  for i in (1:length(list_scenarios))
    n = namez[i]
    scen = list_scenarios[i]
      open("/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$city/$n.json", "w") do f
        write(f, JSON.json(scen, 4))
      end
    end

  # Run analysis(city)
  for i in (1:length(list_scenarios))
    n = namez[i]

    # Run optimizations (BAU and Investment Case)
    m = Model(CPLEX.Optimizer)
    results = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/$city/$n.json")

    # Write unserved load per outage to csv
    unserved_load = results["unserved_load_per_outage"]

    df = DataFrame(transpose(unserved_load))

    # Write results to csv
    CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/unserved_load/$city$n.csv", df, header=false)

    # Save results to csv
    savelist = [
      ## Select inputs
      "dvUnservedLoad",

      ## System sizes
      "PV_kw", "batt_kw", "batt_kwh",

      ## LCC and sub-components
      "lcc",
      ## Outage-related costs in the objective
      "expected_outage_cost",
      "mgTotalTechUpgradeCost",
      "dvMGStorageUpgradeCost",
      # "ExpectedMGFuelCost"
      ]

    # Save results in dataframe
    d = Dict("vars"=>[key for key in savelist],
          "techs"=>[results[key] for key in savelist]
    )
    df = DataFrame(d)

    # Write results to csv
    CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/unserved_load/$city$n results.csv", df)

  end

end
