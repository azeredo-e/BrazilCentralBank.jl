"""
INCLUIR DOCSTRING
"""
module BCB

include("Currency.jl"); using .Currency

export greet

greet() = print("Hello BCB! Its Julia!")

end # module BCB
