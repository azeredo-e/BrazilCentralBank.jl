import Dates.AbstractTime

using BrazilCentralBank
using Documenter

DocMeta.setdocmeta!(BrazilCentralBank, :DocTestSetup, :(using BrazilCentralBank); recursive=true)

makedocs(
    sitename = "BrazilCentralBank.jl",
    format = Documenter.HTML(),
    modules = [BrazilCentralBank],
    pages = [
        "Home" => "index.md",
        "Notes on Implementation" => "impl.md"
    ],
    checkdocs = :export #Only check the docstring of exported functions
)

deploydocs(
    repo="github.com/azeredo-e/BrazilCentralBank.jl.git",
    push_preview=true
)
