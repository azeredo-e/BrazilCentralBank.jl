include("../src/BrazilCentralBank.jl")

using .BrazilCentralBank
using DataFrames
using Dates
using Test

BrazilCentralBank.greetBCB()

#For Ver. 0.2.0
function test_series_code()
    code = BrazilCentralBank.SGSCode(1)
    @assert code.name == "1"
    @assert code.value == 1

    code = BrazilCentralBank.SGSCode("name" => 1)
    @assert code.name == "name"
    @assert code.value == 1

    return true
end

function test_series_code_iter(codes)
    i = 0
    for code in (BrazilCentralBank.SGSCode(i) for i in codes)
        @assert code.name == "$(i+1)"
        @assert code.value == i+1
        i += 1
    end

    @assert length(codes) == i
    
    return true
end

function test_gettimeseries()
    x = gettimeseries(1, last=10)
    @assert x isa DataFrame
    @assert names(x) == ["Date", "1"]
    @assert nrow(x) == 10
    
    x = gettimeseries(Dict("USDBRL" => 1), last=5)
    @assert x isa DataFrame
    @assert names(x) == ["Date", "USDBRL"]
    @assert nrow(x) == 5

    x = gettimeseries(Dict("USDBRL" => 1), start="2021-01-18", finish="2021-01-22")
    @assert x isa DataFrame
    @assert names(x) == ["Date", "USDBRL"]
    @assert nrow(x) == 5
    @assert x[1, "Date"] == Date("2021-01-18")
    @assert x[end, "Date"] == Date("2021-01-22")

    x = gettimeseries((1, 433), last=5)
    @assert x isa DataFrame
    @assert names(x) |> length == 3

    x = gettimeseries((1, 433), last=5, multi=false)
    @assert x isa Array{DataFrame}

    return true
end

@testset begin
    # Ver. 0.1.0
    @test BrazilCentralBank._get_currency_id("USD") == 61
    @test getcurrency_list() isa DataFrame
    @test BrazilCentralBank.CACHE[:CURRENCY_LIST] isa DataFrame
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
    @test test_series_code()
    @test test_series_code_iter((1, 2))
    @test test_series_code_iter([1, 2])
    @test test_series_code_iter(Dict("1" => 1, "2" => 2))
    @test test_gettimeseries()
end
