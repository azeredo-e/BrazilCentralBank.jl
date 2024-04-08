include("../src/BrazilCentralBank.jl")

using .BrazilCentralBank
using DataFrames
using Dates
using Test

BrazilCentralBank.greetBCB()

@testset begin
    # Ver. 0.1.0
    @test BrazilCentralBank._get_currency_id("USD") == 61
    @test getcurrency_list() isa DataFrame
    @test BrazilCentralBank.CACHE["CURRENCY_LIST"] isa DataFrame
    @test gettimeseries("USD", 2023, 2024; side="both") isa DataFrame
    @test gettimeseries(["USD", "CHF"], Date(2023), Date(2024)) isa DataFrame
    try
        df = gettimeseries("test", Date(2020, 12, 01), Date(2020, 12, 05))
    catch err
        @test err isa ArgumentError
    end
    
    # Ver. 0.1.1
    EUR = getCurrency(978)
    @test EUR.symbol == "EUR"
    @test EUR isa BrazilCentralBank.Currency
    @test getCurrency("EUR") isa BrazilCentralBank.Currency
    @test EUR.gettimeseries("USD", Date(2020, 12, 01), Date(2020, 12, 05)) isa DataFrame
    @test EUR.gettimeseries(["USD", "CHF"], Date(2020, 12, 01), Date(2020, 12, 05)) isa DataFrame
    @test EUR.gettimeseries(["USD", "CHF"], Date(2020, 12, 01), Date(2020, 12, 05), groupby="symbol") isa DataFrame

    # Ver. 0.2.0
    

end

