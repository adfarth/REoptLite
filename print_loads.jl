using DelimitedFiles

A = [100 for i in 1:8760]

open("test_loads.txt", "w") do io
           writedlm(io, [A], ',')
       end;
