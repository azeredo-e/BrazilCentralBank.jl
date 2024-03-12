
#* Created by azeredo-e@GitHub

"""
The GetCurrency module is responsible for managing all querys to the BCB Forex (Foreign Exchange) API
"""
module GetCurrency

import Base.@kwdef

using CSV
using DataFrames
using Dates
using Gumbo
using HTTP
using StringEncodings


#TODO: Include exported functions and structs
export _get_symbol 


const CACHE = Dict()
const ENCODING = "ISO-8859-1"


#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                                STRUCT
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-


"""
INCLUDE DOCSTRING
"""
@kwdef struct Currency
    code::Int32
    name::String
    symbol::String
    country_code::Int32
    country_name::String
    type::String
    exclusion_date::Date

    # "Methods"
    getforex::Function = target -> _get_forex(code, target)
end


#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                              FUNCTIONS
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

function _currency_url(currency_id, start_date, end_date)
    start_date = Date(start_date)
    end_date = Date(end_date)

    url = "https://ptax.bcb.gov.br/ptax_internet/consultaBoletim.do?"*
          "method=gerarCSVFechamentoMoedaNoPeriodo&"*
          "ChkMoeda=$currency_id"*
          "&DATAINI=$(Dates.format(start_date, "dd/mm/Y"))"*
          "&DATAFIM=$(Dates.format(end_date, "dd/mm/Y"))"

    return url
end


function _get_currency_id_list()
    if haskey(CACHE, :CURRENCY_ID_LIST)
        return get(CACHE, :CURRENCY_ID_LIST, missing)
    end

    url = "https://ptax.bcb.gov.br/ptax_internet/consultaBoletim.do?"*
          "method=exibeFormularioConsultaBoletim"

    res = HTTP.get(url).body |> String |> parsehtml

    xpath_currency_id = children(res.root[2][2][1][3][1][4][2][1])
    select_vals = [(select[1].text, getattr(select, "value")) for select in xpath_currency_id]
    df = DataFrame(map(idx -> getindex.(select_vals, idx), eachindex(first(select_vals))), [:name, :id])
    df.id = parse.(Int32, df.id)
    
    CACHE["CURRENCY_ID_LIST"] = df

    return df
end


function _get_current_currency_list(_date, n=0)
    url = "http://www4.bcb.gov.br/Download/fechamento/M$(Dates.format(_date, "yyyymmdd")).csv"

    consulta() = try
        return HTTP.get(url)
    catch err
        if isa(err, HTTP.Exceptions.ConnectError)
            if n >= 3
                throw(HTTP.Exceptions.ConnectError(url=url, error="Conexão falhou"))
            end
        end
        return _get_current_currency_list(_date, n+1)
    end

    res = consulta()

    if res.status == 200
        return res
    else
        return _get_current_currency_list(_date - Day(1), 0)
    end
end


function _get_forex(current::Integer, target::Union{String, Int32})
    nothing
end


function _get_currency_id(symbol::String)
    id_list = _get_currency_id_list()
    all_currencies = getcurrency_list()
    df = innerjoin(id_list, all_currencies, on=:name)
    return maximum(df[df.symbol .== symbol, :].id)
end


function _get_symbol(symbol::String, start_date, end_date)
    cid = _get_currency_id(symbol)
    #TODO: Create a check for the dates, max interval is 6 months
    url = _currency_url(cid, start_date, end_date)
    res = HTTP.get(url)
    
    #For some god forsaken reason, HTTP.jl uses a vector of pairs in res.headers, that's why the weird syntax
    if startswith(res.headers[3][2], "text/html")
        doc = parsehtml(String(decode(res.body, ENCODING)))
        res_msg::String = children(doc.root[2][1])[1].text
        res_msg = replace(res_msg, r"^\W+" => "")
        res_msg = replace(res_msg, r"^\W+$" => "")
        msg = "BCB API returned error: $res_msg - $symbol"
        @warn msg
        return nothing
    end

    col_types = Dict(
        :Column1 => Date,
        :Column2 => Int64,
        :Column3 => String,
        :Column4 => String,
        :Column5 => Float64,
        :Column6 => Float64,
        :Column7 => Float64,
        :Column8 => Float64,
    )
    df = CSV.read(
        IOBuffer(decode(res.body, ENCODING)), DataFrame; 
        header=false,
        delim=';',
        decimal=',',
        types=col_types,
        dateformat="ddmmyyyy"
    )
    rename!(df, 
        [:Date,
        :aa,
        :bb,
        :cc,
        :bid,
        :ask,
        :dd,
        :ee]
    )    
    #TODO: How the f* do I do a multilayer index in julia?!
    #? Answer, I can't, changing approach until they fix this
    
    df_bidask = df[:, [:Date, :bid, :ask]]
    rename!(df_bidask,
        :bid => "bid_$symbol",
        :ask => "ask_$symbol"
    )

    return df_bidask
end


"""
INCLUDE DOCSTRING
"""
function getcurrency(code::Integer)
    if haskey(CACHE, :CURRENCY_LIST)
        df = get(CACHE, :CURRENCY_LIST, missing)
    else
        df = getcurrency_list()
    end

    return Currency(
        df[df.code .== code, 1][1],
        df[df.code .== code, 2][1],
        df[df.code .== code, 3][1],
        df[df.code .== code, 4][1],
        df[df.code .== code, 5][1],
        df[df.code .== code, 6][1],
        df[df.code .== code, 7][1]
    )
    
end
function getcurrency(name::String)
    if haskey(CACHE, :CURRENCY_LIST)
        df = get(CACHE, :CURRENCY_LIST, missing)
    else
        df = getcurrency_list()
    end
    #TODO: Include ID
    return Currency(
        df[df.symbol .== name, 1][1],
        df[df.symbol .== name, 2][1],
        df[df.symbol .== name, 3][1],
        df[df.symbol .== name, 4][1],
        df[df.symbol .== name, 5][1],
        df[df.symbol .== name, 6][1],
        df[df.symbol .== name, 7][1]
    )
end


"""
    get_currency_list(convert_to_utf=true) -> DataFrame

List all avaliables currencies in the BCB API, as well as basic information such as currency code,
country of origin, etc.


# Args  
convert_to_utf (Bool, optional): By default BCB information comes in the ISO-8859-1 encoding,
different from the UTF-8 pattern used by Julia. This argument forces the API result to come in UTF-8, 
preventing encoding errors. Defaults to true.

# Returns   
DataFrames.DataFrame: DataFrame with all valiable currencies information.

# Examples

```jldoctest
julia> getcurrency_list()
303×7 DataFrame
 Row │ code   name               symbol    country_code  country_name    type     exclusion_date 
     │ Int32  String             String    Int32         String          String   Date
─────┼──────────────────────────────────────────────────────────────────────────────────────────
   1 │     5  AFEGANE AFEGANIST       AFN           132   AFEGANISTAO         A          missing
                                                ...
```
"""
function getcurrency_list(convert_to_utf::Bool=true)
    if haskey(CACHE, :CURRENCY_LIST)
        return get(CACHE, :CURRENCY_LIST, missing)
    end

    res = _get_current_currency_list(today())
    if convert_to_utf
        df = CSV.read(IOBuffer(decode(res.body, ENCODING)), DataFrame)
    else
        df = CSV.read(IOBuffer(res.body), DataFrame)
    end

    # nomes_originais = names(df)
    rename!(df, 
        [:code,
        :name,
        :symbol,
        :country_code,
        :country_name,
        :type,
        :exclusion_date]
    )
    df = subset(df, :country_code => ByRow(!ismissing))

    df.symbol = map(x -> strip(x, [' ', '\n', '\t']), df.symbol)
    df.name = map(x -> strip(x, [' ', '\n', '\t']), df.name)
    
    df.code = passmissing(convert).(Int32, df.code)
    df.name = passmissing(convert).(String, df.name)
    df.symbol = passmissing(convert).(String, df.symbol)
    df.country_code = passmissing(convert).(Int32, df.country_code)
    df.country_name = passmissing(convert).(String, df.country_name)
    df.type = passmissing(convert).(String, df.type)
    df.exclusion_date = passmissing(x -> Date(x, DateFormat("dd/mm/yyyy"))).(df.exclusion_date)

    CACHE["CURRENCY_LIST"] = df
    
    return df

    # if english_names
    #     CACHE["CURRENCY_LIST"] = df
    #     return df
    # else
    #     rename!(df, nomes_originais)
    #     CACHE["CURRENCY_LIST"] = df
    #     return df
    # end
end


"""
    gettimeseries(symbols::Union{String, Array},
                  start::Any,
                  finish::Any,
                  side::String="ask",
                  groupby::String="symbol")

DataFrame with the time series of selected currencies.

# Args:
symbol (Union{String, Array}): ISO code of desired currencies.
start (Any): Desired start date.
end (Any): Desired end date.

"""
function gettimeseries(symbols::Union{String, Array},
                       start::Any, #TODO: Need to format this to make sure it works independent of the input type (str, int, float, etc)
                       finish::Any,
                       side::String="ask",
                       groupby::String="symbol")
    #TODO: Fix types of a arguments
    if isa(symbols, String)
        symbols = [symbols]
    end
    
    dss = []

    for symbol ∈ symbols
        df_symbol = _get_symbol(symbol, start, finish)
        if !isnothing(df_symbol)
            push!(dss, df_symbol)
        end
    end
    if length(dss) > 0
        df = innerjoin(dss..., on=:Date)
        if side ∈ ("bid", "ask")
            return df[:, Regex("Date|$side")]
        elseif side == "both"
            if groupby == "symbol"
                return df
            elseif groupby == "side"
                #TODO: Create implementation
                nothing
            else
                thow(ArgumentError("Unknown groupby value, use: symbol, side"))
            end
        else
            thow(ArgumentError("Unknown side value, use: bid, ask, both"))
        end
    else
        @info "No values passed to the gettimeseries function."
        return nothing
    end
end


# function __init__() #TODO: fix types
#     precompile(getcurrency_list)
#     precompile(getcurrency_info)
#     precompile(gettemporalseries)
# end

end # Currency module
