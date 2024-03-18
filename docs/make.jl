import Dates.AbstractTime

using BrazilCentralBank
using Documenter

DocMeta.setdocmeta!(BrazilCentralBank, :DocTestSetup, :(using BrazilCentralBank); recursive=true)

makedocs(
    sitename = "BrazilCentralBank.jl",
    format = Documenter.HTML(),
    modules = [BrazilCentralBank],
)

deploydocs(
    repo="github.com/azeredo-e/BrazilCentralBank.jl.git",
)
