"""
INCLUIR DOCSTRING
"""
module BCB

include("Currency.jl"); using .Currency

export greet

greet() = print("Hello, BCB! It\'s Julia!")

end # module BCB
