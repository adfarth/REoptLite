using CPLEX
using JuMP
using REoptLite
using CSV, DataFrames
using JSON

# This is for the BAU cases ONLY and is to report year 1 energy bill costs

# City names
cities = ["Atlanta", "Albuquerque", "Baltimore", "Boulder", "Chicago", "Duluth", "Helena",
"Houston", "LosAngeles", "Miami", "Minneapolis", "Phoenix", "SanFrancisco", "Seattle"]

# Building types
building_types = ["hosp", "school", "warehouse"]

# Master file name
master = "master" # "master"

function RunAndSave(city, bldg)

    # Look through scenarios for each building type
    scen_objs = ["_b_"] # "_b_",  "_br_", "_brc_", "_brch_"  "_br_", "_brch_"

    # For each objective
    for obj in scen_objs

        # Run BAU and Techs case
        bau_file = "$city $bldg$obj"*"bau"
        # techs_file = "$city $bldg$obj"*"techs"

        # Results file savename
        savename = bau_file[1:end-4]

        print("$savename \n")

        # Run optimizations (BAU and Investment Case)
        m = Model(CPLEX.Optimizer)
        results_bau = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/USA_Scenarios/$bau_file.json")

        #m = Model(CPLEX.Optimizer)
        #results_techs = run_reopt(m, "/Users/amandafarthing1/.julia/dev/REoptLite/test/scenarios/USA_Scenarios/$techs_file.json")

        if obj == "_b_"
            # Shortened save list for b case bc it doesn't have outage outputs
            savelist = [
            ## System sizes
            "PV_kw", "batt_kw", "batt_kwh",

              ## Select inputs
              "TOU_demand_rates",
              "monthly_demand_rates",

              # Year 1 costs
              "year_one_utility_kwh",
              "year_one_energy_cost",
              "year_one_demand_cost",
              "year_one_demand_tou_cost",
              "year_one_demand_flat_cost",
              "year_one_export_benefit",
              "year_one_fixed_cost" ,
              "year_one_min_charge_adder",
              "year_one_bill",
            ]
        end

        # Save results in dataframe
        d = Dict("vars"=>[key for key in savelist],
              "bau"=>[results_bau[key] for key in savelist],
              # "techs"=>[results_techs[key] for key in savelist]
        )
        df = DataFrame(d)

        # Write results to csv
        CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/USA/0_EnergyCosts/$savename.csv", df) # $savename (file name)

        # Time series results to save, for techs case
        d = Dict("net_load"=>results_bau["net_load"],
                  "building_load"=>results_bau["building_load"],
                  "energy_rates"=>results_bau["energy_rates"],
        )
        df2 = DataFrame(d)

        # Write 8760 results to csv
        CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/USA/0_EnergyCosts/$savename 8760.csv", df2) # $savename (file name)

    end

end

# Run analyses and save results
for i in (1:length(cities))
  city = cities[i]
  for bldg in building_types
      print("$city $bldg")
    RunAndSave(city, bldg)
  end
end
