"""
INCLUIR DOCSTRING
"""
module BCB

include("Currency.jl"); #using .GetCurrency
export getcurrency_list, gettimeseries


export greet

greet() = print("Hello, BCB! It\'s Julia!\n")

end # module BCB
