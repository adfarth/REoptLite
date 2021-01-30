# *********************************************************************************
# REopt, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this list
# of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or other
# materials provided with the distribution.
#
# Neither the name of the copyright holder nor the names of its contributors may be
# used to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
# *********************************************************************************
struct Scenario
    site::Site
    pvs::Array{PV, 1}
    storage::Storage
    electric_tariff::ElectricTariff
    electric_load::ElectricLoad
    electric_utility::ElectricUtility
    financial::Financial
    generator::Generator
    emissions::Emissions # ADF
end


function Scenario(d::Dict)
    # TODO add validate! functions for each input struct

    site = Site(;dictkeys_tosymbols(d["Site"])...)

    pvs = PV[]
    if haskey(d, "PV")
        if typeof(d["PV"]) <: AbstractArray
            for (i, pv) in enumerate(d["PV"])
                check_pv_tilt!(pv, site)
                if !(haskey(pv, "name"))
                    pv["name"] = string("PV", i)
                end
                push!(pvs, PV(;dictkeys_tosymbols(pv)...))
            end
        elseif typeof(d["PV"]) <: AbstractDict
            check_pv_tilt!(d["PV"], site)
            push!(pvs, PV(;dictkeys_tosymbols(d["PV"])...))
        else
            error("PV input must be Dict or Dict[].")
        end
    end

    if haskey(d, "Financial")
        financial = Financial(; dictkeys_tosymbols(d["Financial"])...)
    else
        financial = Financial()
    end

    if haskey(d, "ElectricUtility")
        electric_utility = ElectricUtility(; dictkeys_tosymbols(d["ElectricUtility"])...)
    else
        electric_utility = ElectricUtility()
    end

    if haskey(d, "Storage")
        # only modeling electrochemical storage so far
        storage_dict = Dict(:elec => dictkeys_tosymbols(d["Storage"]))
        storage = Storage(storage_dict, financial)
    else
        storage_dict = Dict(:elec => Dict(:max_kw => 0))
        storage = Storage(storage_dict, financial)
    end

    electric_load = ElectricLoad(; dictkeys_tosymbols(d["ElectricLoad"])...)

    electric_tariff = ElectricTariff(; dictkeys_tosymbols(d["ElectricTariff"])...,
                                       year=electric_load.year # why does this get sent 2017 as the year? (ADF)
                                    )

    if haskey(d, "Generator")
        generator = Generator(; dictkeys_tosymbols(d["Generator"])...)
    else
        generator = Generator(; max_kw=0)
    end

    # ADF
    if haskey(d, "Emissions")
        emissions = Emissions(; dictkeys_tosymbols(d["Emissions"])...,
                                analysis_years=financial.analysis_years
                            )
    else
        emissions = Emissions(; balancing_authority=0)
    end

    return Scenario(
        site,
        pvs,
        storage,
        electric_tariff,
        electric_load,
        electric_utility,
        financial,
        generator,
        emissions # ADF
    )
end


function check_pv_tilt!(pv::Dict, site::Site)
    if !(haskey(pv, "tilt"))
        pv["tilt"] = site.latitude
    end
end
