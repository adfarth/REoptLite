# To print select results

printlist = ["PV_kw", "batt_kw", "batt_kwh",
  "year_one_energy_produced_PV",
  # "lcc",
  # "net_capital_costs_plus_om",
  "total_energy_cost",
  "total_demand_cost",
  "total_fixed_cost",
  # "total_min_charge_adder",
  "Total_CO2Cost",
  "Total_HealthCost",
  "total_export_benefit",
  "year_one_export_benefit",
  "year_one_utility_kwh",
  # "GridToLoad"
  # "GridtoBatt"
  ]
  #"mgTotalTechUpgradeCost",
  # "dvMGStorageUpgradeCost",
  # "ExpectedMGFuelCost",
  #"total_unserved_load",
  # "expected_outage_cost"]
#  "PV_kw_PurchaseSize",
# "PVmg_kw",
# "PV_mg_kw"
# "total_unserved_load",
# "expected_outage_cost"
# "mgPVtoBatt"
# "mgPVtoCurtail"
# "mgPVtoLoad"
# **PV Generation arrays:**
#PVtoLoad # sum(results["PVtoLoad"])
#PVtoCUR # sum(results["PVtoCUR"])
#PVtoNEM # sum(results["PVtoNEM"])
#PVtoWHL # sum(results["PVtoWHL"])
#PVtoBatt # sum(results["PVtoBatt"])



for key in printlist
    print(key," : ", results[key], "\n")
    # print(results[key],"\n")
    # print(key, "\n")
end


# Cost of carbon 2020 - 2045
# 51.786, 52.7724, 53.7588, 54.7452, 55.7316, 56.718, 57.7044, 58.6908, 59.6772, 60.6636, 61.65, 62.883, 64.116, 65.349, 66.582, 67.815, 69.048, 70.281, 71.514, 72.747, 73.98, 74.9664, 75.9528, 76.9392, 77.9256, 78.912
