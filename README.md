# BCB.jl

BCB.jl é uma interface na linguagem de programação Julia para a API de dados do Banco Central do Brasil.  
O projeto foi inspirado por [python-bcb](https://github.com/wilsonfreitas/python-bcb) criado por wilsonfreitas@GitHub.

BCB.jl is an interface in the Julia programming language for the data API of Brazil's Central Bank (BCB).  
The project was inspired by [python-bcb](https://github.com/wilsonfreitas/python-bcb) created by wilsonfreitas@GitHub.

## About the project

> Current release: 0.1.0 (2024-03-14)

Based on the python-bcb package for python, BCB.jl aims to provide the same level of features to the Julia Language. Currently the package can interact with the foreign exchange (FOREX) prices as shows in the time series availiable in the BCB's site.

Right now the project is in its early days and the implementation still resembles a lot the original python project. Future updates include a `Currency` type for better dealing with currencies as well as the inclusion of other data sources from the BCB's site such as interest rates, inflation, etc.

The final goal is for this to be a comprehensive set of tools for anyone trying to analyse the brazilian economy using Julia!

## Instalation

Source code are avaliable in this project directory, but instalation through Julia's package manager will be avaliable soon.

```julia
julia> using Pkg; Pkg.add(BCB)
```
