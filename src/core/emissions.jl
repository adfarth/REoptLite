# Process marginal emissions rates from csvs

struct Emissions

    ton_kWh_CO2::Array{Real,2} # 8760 x n years [tonnes / kWh]
    ton_kWh_SO2::Array{Real,2} # [tonnes/kWh]
    ton_kWh_NOx::Array{Real,2} # [tonnes/kWh]

    cost_ton_CO2::Real # TODO: Consider also making this an array of values from EPA table
    # TODO: Make EASIUR costs an array of seasonal costs
    cost_ton_SO2::Real # Obtain from EASIUR TODO: make cost_ton_SO2
    cost_ton_NOx::Real # Obtain from EASIUR

end

function Emissions(;
    year::Int=2021,
    analysis_years::Int = 25,

    cost_ton_CO2::Real = 0.0, # Prev: [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00],
    cost_ton_SO2::Real = 0.0,
    cost_ton_NOx::Real = 0.0,

    balancing_authority::Union{Missing, Int64} = missing
    )

    if !ismissing(balancing_authority) # make sure ba is supplied
        if (balancing_authority==0) # when Emissions inputs are missing
                # Set arrays to zero
                ton_kWh_CO2 = zeros(Float64, 8760, analysis_years)
                ton_kWh_SO2 = zeros(Float64, 8760, analysis_years)
                ton_kWh_NOx = zeros(Float64, 8760, analysis_years)

        else
        # TODO set path with joinpath(dirname(pathof(REoptLite)), "..", "data") once REopt is a pkg
        lib_path = joinpath(dirname(@__FILE__), "..", "..", "data/mers")
        profile_path = joinpath(lib_path, string("p$balancing_authority.csv"))

        # Can use this, requiring importing DataFrame
        mers = CSV.File(profile_path, header=1) |> DataFrame
        # Or this, which might always get warning that CSV is depreciated?
        # data = CSV.read(profile_path, header=1)

        # TODO: add error check for year (must be between 2018 and (2050-analysis years))
        ton_kWh_CO2 = CreateEmissionsMatrix("CO2", mers, year, analysis_years)
        ton_kWh_SO2 = CreateEmissionsMatrix("SO2", mers, year, analysis_years)
        ton_kWh_NOx = CreateEmissionsMatrix("NOx", mers, year, analysis_years)

        end

    else
        error("Cannot construct Emissions. You must provide the balancing authority # from Cambium as an Int.")
    end

    Emissions(
        ton_kWh_CO2,
        ton_kWh_SO2,
        ton_kWh_NOx,

        cost_ton_CO2,
        cost_ton_SO2,
        cost_ton_NOx
    )

end

function CreateEmissionsMatrix(emission::String, mers::DataFrame, year::Int, analysis_years::Int) # (might not need these here)

    # Select only columns for this emission
    even = mers[!, Regex(emission)]
    odd = mers[!, Regex(emission)]

    # Add 1 to year of each column name
    odd_names = names(odd)
    for i in 1:length(odd_names)
        int = parse(Int64, odd_names[i][1:4])
        odd_names[i] = string(int+1, "_$emission")
    end

    rename!(odd, odd_names)

    # concat dfs
    df = hcat(even, odd)

    # reorder columns
    df = select!(df, sort(names(df)))

    # filter columns for desired years
    start_index = findall( x -> occursin(string(year), x), names(df))[1]
    keep = names(df)[start_index:(start_index + analysis_years - 1)]
    df = df[:, keep]
    emissions_matrix = convert(Matrix,df)

    # return 8760 x analysis_years matrix of emissions rates / kWh
    return emissions_matrix

end
