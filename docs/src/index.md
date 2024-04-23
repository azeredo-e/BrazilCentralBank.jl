# BrazilCentralBank.jl Documentation

Welcome to the documentation page!

## About the Project

> Current release: 0.2.0 (2024-04-23)

Based on the python-bcb package for python, BrazilCentralBank.jl aims to provide the same level of features to the Julia Language. Currently the package can interact with the foreign exchange (FOREX) prices as shows in the time series availiable in the Brazil's Central Bank (BCB) website.

Right now the project is in its early days and the implementation still resembles a lot the original python project. Future updates include the addition other data sources from the BCB's site such as interest rates, inflation, etc.

The final goal is for this to be a comprehensive set of tools for anyone trying to analyse the brazilian economy using Julia!

## Instalation

Source code are avaliable in this project directory, but instalation through Julia's package manager is also avaliable.

```julia
julia> using Pkg; Pkg.add(BrazilCentralBank)
```
