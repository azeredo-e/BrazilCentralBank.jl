include("../src/BCB.jl")

using .BCB
using DataFrames
using Dates
using Test

greet()

@testset begin
    @test BCB._get_currency_id("USD") == 61
    @test getcurrency_list() isa DataFrame
    @test BCB.CACHE["CURRENCY_LIST"] isa DataFrame
    @test gettimeseries("USD", 2023, 2024; side="both") isa DataFrame
    @test gettimeseries(["USD", "CHF"], Date(2023), Date(2024)) isa DataFrame
    try
        df = gettimeseries("test", Date(2020, 12, 01), Date(2020, 12, 05))
    catch err
        @test err isa ArgumentError
    end
end
