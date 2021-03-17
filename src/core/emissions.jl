# Process marginal emissions rates from csvs

struct Emissions

    ton_kWh_CO2::Array{Real,2} # 8760 x n years [tonnes / kWh]
    ton_kWh_SO2::Array{Real,2} # 8760 x n years [tonnes/kWh]
    ton_kWh_NOx::Array{Real,2} # 8760 x n years [tonnes/kWh]

    cost_ton_CO2::Real # TODO: Consider also making this an array of values from EPA table
    # TODO: Automatically populate these using EASIUR python code (https://drive.google.com/drive/folders/1HQtREJ5MBDBM3wXYJNvQA_qkapZc91bX)
    # NOTE: I was getting an error when using type Real or Float. The input was being interpreted as type (Any)
    # NOTE (cont): I also get an error when only allowing type Any, if the user does not supply an Emissions dict. I'm not sure why type Float64 isn't matching type(Any)
    cost_ton_SO2::Union{Array{Any,1}, Array{Float64,1}} #Array{Any,1}#Array{<:Real,1} # From EASIUR. Array values corresponds to a season [Winter, Spring, Summer, Fall]
    cost_ton_NOx::Union{Array{Any,1}, Array{Float64,1}}#Array{<:Real,1} # From EASIUR. Array values corresponds to a season [Winter, Spring, Summer, Fall]

end

function Emissions(;
    year::Int=2020, # start year for emissions
    analysis_years::Int = 25,
    balancing_authority::Union{Missing, Int64} = missing,

    cost_ton_CO2::Real = 0.0, 
    cost_ton_SO2::Union{Array{Any,1}, Array{Float64,1}}=[0.0, 0.0, 0.0, 0.0], # was <:Real
    cost_ton_NOx::Union{Array{Any,1}, Array{Float64,1}}=[0.0, 0.0, 0.0, 0.0] # was <:Real
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
        int = parse(Int64, odd_names[i][1:4]) # get year
        odd_names[i] = string(int+1, "_$emission")
    end

    rename!(odd, odd_names)

    # concat dfs (even and odd years)
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
