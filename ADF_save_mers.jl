# Only have to run this once
# Saving mers for years 2020-2045

using CSV, DataFrames

# to_save = results_bau["ton_kWh_CO2"]
to_save = results_bau["ton_kWh_SO2"]
# to_save = results_bau["ton_kWh_NOx"]

savename = "ton_kWh_SO2_2020_2045"

# Write net_load in bau and techs case to csv
df3 = DataFrame(to_save)

# Write results to csv
CSV.write("/Volumes/GoogleDrive/My Drive/0_Michigan/Master's Thesis/Results/mers/$savename.csv", df3) # $savename (file name)
