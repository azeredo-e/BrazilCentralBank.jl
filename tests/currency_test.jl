include("../src/BCB.jl")

using .BCB
using DataFrames
using Dates

greet()

@assert BCB._get_currency_id("USD") == 61
println("Passed 1 test")

@assert getcurrency_list() isa DataFrame
println("Passed 2 test")

@assert BCB.CACHE["CURRENCY_LIST"] isa DataFrame
println("Passed 3 test")

@assert gettimeseries("USD", 2023, 2024; side="both") isa DataFrame
println("Passed 4 test")

@assert gettimeseries(["USD", "CHF"], Date(2023), Date(2024)) isa DataFrame
println("Passed 5 test")

try
    @assert gettimeseries("test", Date(2020, 12, 01), Date(2020, 12, 05)) == nothing
catch err
    if err isa ArgumentError
        println("Passed 6 test")
    end
end

