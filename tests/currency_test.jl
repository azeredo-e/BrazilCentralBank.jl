include("../src/BCB.jl")

using .BCB
using DataFrames

greet()

@assert getcurrency_list() isa DataFrame
println("Passed 1 test")

@assert BCB.CACHE["CURRENCY_LIST"] isa DataFrame
println("Passed 2 test")

@assert gettimeseries("AFN", "2023", "2024") isa DataFrame
println("Passed 3 test")



