using CPLEX
using JuMP
using REoptLite
using CSV, DataFrames
using JSON

# City names
cities = ["Albuquerque", "Atlanta", "Baltimore", "Boulder", "Chicago", "Duluth",
"Helena", "Houston", "LosAngeles", "Miami", "Minneapolis", "Phoenix", "SanFrancisco", "Seattle"]

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
  function create_BAU(dict)
    BAU = deepcopy(dict)

    BAU["PV"]["max_kw"] = 0.0
    BAU["Storage"]["max_kw"] = 0.0
    BAU["Storage"]["max_kwh"] = 0.0

    return BAU
  end

  function create_objs(dict)
    b = deepcopy(dict) # obj: min cap + O&M + energy bill

    b["Financial"]["include_climate_in_obj"] = false
    b["Financial"]["include_health_in_obj"] = false
    b["Financial"]["include_resilience_in_obj"] = false

    return b

  end

  # For each building type: Create bau & techs files (hosp, school, and warehouse are the "inv case" jsons)
  hosp_bau = create_BAU(hosp)
  school_bau = create_BAU(school)
  warehouse_bau = create_BAU(warehouse)

  # For each bldg, for bau case, create objective scenarios
  hosp_b_bau = create_objs(hosp_bau)
  school_b_bau = create_objs(school_bau)
  warehouse_b_bau = create_objs(warehouse_bau)

  # Write all dicts to json files
  list_scenarios = [hosp_b_bau, school_b_bau, warehouse_b_bau]

  namez = ["hosp", "school", "warehouse"]

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

  end

end
