"""
INCLUIR DOCSTRING
"""
module BCB

include("Currency.jl"); using .GetCurrency

#TODO: Include exported functions
export greet

greet() = print("Hello, BCB! It\'s Julia!\n")

end # module BCB
