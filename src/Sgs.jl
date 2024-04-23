
# Created by azeredo-e@GitHub

using Dates
using HTTP
using JSON
using DataFrames

# A função get usa a função _codes para entender o input do usuário
# com isso ela manda para a classe SGSCode para guardar o valor como
# se fosse um struct


#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                                STRUCTS
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

struct SGSCode{S<:AbstractString, N<:Integer}
    name::S
    value::N

    function SGSCode(code::Union{Integer, AbstractString})
        new{AbstractString, Integer}(string(code), convertToInt32(code))
    end
    function SGSCode(code::Pair)
        new{AbstractString, Integer}(code.first, convertToInt32(code.second))
    end
    #TODO: Add support to named tuples
    # function SGSCode(code::Tuple{AbstractString, Number})
    #     typeof(code[1]) <: AbstractString ? 
    #         new{AbstractString, Number}(string(code[1]), convertToInt32(code[2])) :
    #         new{AbstractString, Number}(string(code[2]), code[1])
    # end
    # function SGSCode(code::AbstractArray)
    #     typeof(code[1]) <: AbstractString ? 
    #         new{AbstractString, Number}(string(code[1]), convertToInt32(code[2])) :
    #         new{AbstractString, Number}(string(code[2]), convertToInt32(code[1]))
    # end
end


#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                              FUNCTIONS
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

function convertToInt32(input)
    if typeof(input) <: Number
        return Int32(input)
    elseif typeof(input) <: AbstractString
        return parse(Int32, input)
    else
        throw(ArgumentError("Input must be a number or string"))
    end
end


function _get_url_payload(code, start_date, end_date, last)
    payload = Dict(:format => "json")
    
    end_date_exists = @isdefined end_date

    if last == 0
        if start_date !== nothing || end_date !== nothing
            payload[:dataInicial] = Dates.format(Date(start_date), "dd/mm/Y")
            end_date = end_date_exists ? end_date : today()
            payload[:dataFinal] = Dates.format(Date(end_date), "dd/mm/Y")
        end
        url = "http://api.bcb.gov.br/dados/serie/bcdata.sgs.$code/dados"
    else
        url = "http://api.bcb.gov.br/dados/serie/bcdata.sgs.$code/dados/ultimos/$last"
    end

    return Dict(:payload => payload, :url => url)
end


function _format_df(df, code)
    if :datafim in names(df)
        rename!(df,
            :data => "Date",
            :valor => code.name,
            :datafim => "enddate"
        )
    else
        rename!(df,
            :data => "Date",
            :valor => code.name,
        )
    end

    df = select(df, "Date", names(df, Not("Date")))

    if "Date" in names(df) 
        df.Date = passmissing(x -> Date(x, DateFormat("dd/mm/yyyy"))).(df.Date)
    end
    if "enddate" in names(df) 
        df.enddate = passmissing(x -> Date(x, DateFormat("dd/mm/yyyy"))).(df.enddate)
    end

    df[!, code.name] = parse.(Float64, df[:, code.name])
    
    #TODO: Implement frequency, maybe create a type or something
    return df
end


"""
    gettimeseries(codes; start=nothing, finish=nothing,
                  last=0, multi=true)

Returns a DataFrame with the SGS time series.

# Args
codes(Integer, AbstractString, Dict{AbstractString, Number}, Tuple{Integer, Vararg{Int}}):\\
    The codes for the desired time series.\\
    The codes can be in one of the following formats:\\
    - `Integer`: time-series code\\
    - `Tuple`: tuple containing the desired time-series' codes\\
    - `Dict`: Dictionary with the pair ("SeriesName" => code)\\
    When using a Dict, you can define a name for the series. This is the name to be used in the column
    name, if not defined, it will default to the code.

start(Number, String...): Any value that can be converted to a date with `Date()` is valid.\\
Start date of the series.

end(Number, String...): Any value that can be converted to a date with `Date()` is valid.\\
End date of the series.

last(Integer): If last is bigger than 0, `start` and `end` are ignored. Return the
last *n* values of the series.

multi(Bool): If true, returns a single series with multiple variable, if false,
    returns a tuple of single variable series.

# Returns

`DataFrame`: univariate or multivariate time series when `multi=true`.
`Vector{DataFrame}`: vector of univariate time series when `multi=false`.

# Raises
ErrorException: Failed to fetch time-series data.

# Examples

```jldoctest
julia> gettimeseries(1, last=5)
5×2 DataFrame
 Row │ Date        1       
     │ Date        Float64
─────┼─────────────────────
   1 │ 2024-04-16   5.2635
   2 │ 2024-04-17   5.2469
   3 │ 2024-04-18   5.2512
   4 │ 2024-04-19   5.2269
   5 │ 2024-04-22   5.2043

julia> gettimeseries(Dict("USDBRL" => 1), last=5)
5×2 DataFrame
 Row │ Date        USDBRL  
     │ Date        Float64
─────┼─────────────────────
   1 │ 2024-04-15   5.1746
   2 │ 2024-04-16   5.2635
   3 │ 2024-04-17   5.2469
   4 │ 2024-04-18   5.2512
   5 │ 2024-04-19   5.2269

julia> gettimeseries(Dict("USDBRL" => 1), start="2021-01-18", finish="2021-01-22")
5×2 DataFrame
 Row │ Date        USDBRL  
     │ Date        Float64
─────┼─────────────────────
   1 │ 2021-01-18   5.2788
   2 │ 2021-01-19   5.2945
   3 │ 2021-01-20   5.3033
   4 │ 2021-01-21   5.3166
   5 │ 2021-01-22   5.4301

julia> gettimeseries((1, 433), last=5)
10×3 DataFrame
 Row │ Date        1             433
     │ Date        Float64?      Float64?
─────┼──────────────────────────────────────
   1 │ 2023-11-01  missing             0.28
   2 │ 2023-12-01  missing             0.56
   3 │ 2024-01-01  missing             0.42
   4 │ 2024-02-01  missing             0.83
   5 │ 2024-03-01  missing             0.16
   6 │ 2024-04-16        5.2635  missing
   7 │ 2024-04-17        5.2469  missing
   8 │ 2024-04-18        5.2512  missing
   9 │ 2024-04-19        5.2269  missing
  10 │ 2024-04-22        5.2043  missing

julia> gettimeseries((1, 433), last=5, multi=false)
2-element Vector{DataFrames.DataFrame}:
 5×2 DataFrame
 Row │ Date        1       
     │ Date        Float64
─────┼─────────────────────
   1 │ 2024-04-16   5.2635
   2 │ 2024-04-17   5.2469
   3 │ 2024-04-18   5.2512
   4 │ 2024-04-19   5.2269
   5 │ 2024-04-22   5.2043
 5×2 DataFrame
 Row │ Date        433     
     │ Date        Float64
─────┼─────────────────────
   1 │ 2023-11-01     0.28
   2 │ 2023-12-01     0.56
   3 │ 2024-01-01     0.42
   4 │ 2024-02-01     0.83
   5 │ 2024-03-01     0.16
```
"""
function gettimeseries(codes; start=nothing, finish=nothing,
                       last=0, multi=true)
    dfs::Vector{DataFrame} = []

    if typeof(codes) <: AbstractString
        codes = [codes]
    end

    for code in (SGSCode(i) for i in codes)
        urd = _get_url_payload(code.value, start, finish, last)
        res = HTTP.get(urd[:url]; query=urd[:payload])
        if res.status != 200
            throw(ErrorException("Download error: code = $(code.value)"))
        end
        try
            df = res.body |> String |> JSON.parse |> DataFrame
            df = _format_df(df, code)
            push!(dfs, df)
        catch err
            if err isa ErrorException
                @warn "Invalid time series code, code = $(code.value)"
            end
        end
    end
    if length(dfs) == 0
        return nothing
    elseif length(dfs) == 1
        return dfs[1]
    else
        if multi
            df_join = outerjoin(dfs..., on=:Date)
            sort!(df_join, :Date)
            return df_join
        else
            return dfs
        end
    end
end


