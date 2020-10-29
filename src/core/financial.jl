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
Base.@kwdef struct Financial
    om_cost_escalation_pct::Float64 = 0.025
    elec_cost_escalation_pct::Float64 = 0.023
    offtaker_tax_pct::Float64 = 0.26
    offtaker_discount_pct = 0.083
    two_party_ownership::Bool = false
    owner_tax_pct::Float64 = 0.26
    owner_discount_pct::Float64 = 0.083
    analysis_years::Int = 25
    macrs_five_year::Array{Float64,1} = [0.2, 0.32, 0.192, 0.1152, 0.1152, 0.0576]  # IRS pub 946
    macrs_seven_year::Array{Float64,1} = [0.1429, 0.2449, 0.1749, 0.1249, 0.0893, 0.0892, 0.0893, 0.0446]
    VoLL::Union{Array{R,1}, R} where R<:Real = 1.00
    microgrid_premium_pct::Float64 = 0.3

    ## CO2 impacts (ADF)
    tonCO2_kw::Float64 = 0.00  # Regional emissions factor from EPA AVERT [annual avoided tons CO2 per kW solar PV]
    # Cost of carbon in 2019$
    # default of 30 zeros, but only first i in 1:analysis_years used in reopt.jl
    cost_tonCO2::Array{Real,1} = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00]
    ## Health impacts (ADF)
    health_cost_kwh::Float64 = 0.00 # Regional benefit (negative cost) per kWh from EPA https://www.epa.gov/statelocalenergy/estimating-health-benefits-kilowatt-hour-energy-efficiency-and-renewable-energy#Screening-level%20regional%20estimates
end
