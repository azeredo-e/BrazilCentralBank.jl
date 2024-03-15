"""
The BrazilCentralBank package aims to provide a user interface to Brazil's Central Bank (BCB) web data API.

AUTHOR: azeredo-e@github\\
GITHUB: github.com/azeredo-e/BCB.jl\\
LICENSE: MIT License\\
VERSION: 0.1.0
"""
module BrazilCentralBank

include("Currency.jl"); #using .GetCurrency
export getcurrency_list, gettimeseries


greetBCB() = print("Hello, BCB! It\'s Julia!\n")

end # module BCB
