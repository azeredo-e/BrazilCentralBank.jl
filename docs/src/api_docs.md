# API Documentation

```@docs
BrazilCentralBank
getcurrency_list(;convert_to_utf=true)
Currency
Currency(code::Integer)
Currency(code::String)
getcurrencyseries(symbols::Union{String, Array}, start::Union{AbstractTime, AbstractString, Number}, finish::Union{AbstractTime, AbstractString, Number}; side::String="side", groupby::String="symbol")
gettimeseries(codes; start=nothing, finish=nothing, last=0, multi=true)
```
