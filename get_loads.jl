using CPLEX
using JuMP
using REoptLite
using CSV, DataFrames
using JSON

# City names
cities = ["Albuquerque", "Atlanta", "Baltimore", "Boulder", "Chicago", "Duluth",
"Helena", "Houston", "LosAngeles", "Miami", "Minneapolis", "Phoenix", "SanFrancisco", "Seattle"]

function GenerateJSONs(city::String)
    scenario_path = "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/get_loads/get_loads.json" #

  # Open city name json
  dict = Dict()
  open(scenario_path, "r") do f
      # global dict
      dict=JSON.parse(f)  # parse and transform data
  end

  # Update city name
  dict["ElectricLoad"]["city"] = city

  # Update building-specific values for each building type
  hosp = deepcopy(dict)
  school = deepcopy(dict)
  warehouse = deepcopy(dict)

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

  # Write all dicts to json files
  list_scenarios = [hosp, school, warehouse]

  namez = ["hosp", "school", "warehouse"]

  # Write each to json
  for i in (1:length(list_scenarios))
    n = namez[i]
    scen = list_scenarios[i]
      open("/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/get_loads/$city $n.json", "w") do f
        write(f, JSON.json(scen, 4))
      end
    end

end


function RunAndSaveLoads(city, bldg)

  scenario_path = "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/get_loads/$city $bldg.json" #

  m = Model(CPLEX.Optimizer)
  results = run_reopt(m, "$scenario_path")

  # Write loads_kw to file
  building_load = results["building_load"]

  df = DataFrame(BuildingLoad = building_load)

  # Write results to csv
  CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/USA/building_loads/$city$bldg.csv", df) # , header=false

end

# Generate JSONs
for i in (1:length(cities))
  c = cities[i]
  GenerateJSONs(c)
end

# Run (simplified) model and save bldg loads
for i in (1:length(cities))
  city = cities[i]
  for bldg in ["hosp", "school", "warehouse"]
    RunAndSaveLoads(city, bldg)
  end
end
