# BrazilCentralBank.jl Documentation

Welcome to the documentation page!

## About the Project

> Current release: 0.1.0 (2024-03-14)

Based on the python-bcb package for python, BrazilCentralBank.jl aims to provide the same level of features to the Julia Language. Currently the package can interact with the foreign exchange (FOREX) prices as shows in the time series availiable in the Brazil's Central Bank (BCB) website.

Right now the project is in its early days and the implementation still resembles a lot the original python project. Future updates include a `Currency` type for better dealing with currencies as well as the inclusion of other data sources from the BCB's site such as interest rates, inflation, etc.

The final goal is for this to be a comprehensive set of tools for anyone trying to analyse the brazilian economy using Julia!

## Instalation

Source code are avaliable in this project directory, but instalation through Julia's package manager will soon be avaliable.

```julia
julia> using Pkg; Pkg.add(BrazilCentralBank)
```

## API Documentation

```@docs
BrazilCentralBank
getcurrency_list(;convert_to_utf=true)
gettimeseries(symbols::Union{String, Array}, start::Union{AbstractTime, AbstractString, Number}, finish::Union{AbstractTime, AbstractString, Number}; side::String="side", groupby::String="symbol")
```
