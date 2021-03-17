# To print select results

printlist = [
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
  ## Other vars
  #"year_one_export_benefit",
  #"year_one_utility_kwh",
  # "GridToLoad"
  # "GridtoBatt"
  ## PV Production
  #"year_one_energy_produced_PV",
  #PVtoLoad # sum(results["PVtoLoad"])
  #PVtoCUR # sum(results["PVtoCUR"])
  #PVtoNEM # sum(results["PVtoNEM"])
  #PVtoWHL # sum(results["PVtoWHL"])
  #PVtoBatt # sum(results["PVtoBatt"])
  ]

  #"total_unserved_load",
#  "PV_kw_PurchaseSize",
# "PVmg_kw",
# "PV_mg_kw"
# "total_unserved_load",
# "mgPVtoBatt"
# "mgPVtoCurtail"
# "mgPVtoLoad"
# sum(results["net_load"])


print("\n \n")
for key in printlist
    print(key," : ", results_bau[key], "\n")
    #print(results_techs[key],"\n")
     #print(key, "\n")
end
