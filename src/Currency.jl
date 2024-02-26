
""" #TODO: Descobrir como fazer DOCSTRING de módulo
O módulo (inserir aqui o nome do módulo) tem como realizar as consultas no site de conversor de moedas do BCB.
"""

#* Created by azeredo-e@GitHub

import Base.@kwdef

using CSV
using DataFrames
using Dates
using HTTP
using StringEncodings

const CACHE = Dict()



function _get_current_currency_list(_date, n=0)
    url = "http://www4.bcb.gov.br/Download/fechamento/M$(Dates.format(_date, "yyyymmdd")).csv"

    consulta() = try
        return HTTP.request("GET", url)
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

"""
    get_currency_list(convert_to_utf=true, english_names=true)::DataFrame

Lista todas as moedas disponíveis pela API assim como informações básicas como código, país de origem, etc.

# Args  
convert_to_utf (Bool, optional): Por padrão os dados do BCB vem com a encoding "ISO-8859-1" diferente do padrão UTF-8 de Julia, esse parâmetro força a conversão, prevenindo erros de encoding. Defaults to true.

# Returns   
DataFrames.DataFrame: DataFrame com todas as informações da moedas.

# Examples

```jldoctest
julia> getcurrency_list()
303×7 DataFrame
 Row │ code   name               symbol    country_code  country_name    type     exclusion_date 
     │ Int32  String             String    Int32         String          String   Date     
─────┼──────────────────────────────────────────────────────────────────────────────────────────
   1 │     5  AFEGANE AFEGANIST       AFN           132  AFEGANISTAO  …        A         missing
                                                ...
```
"""
function getcurrency_list(convert_to_utf::Bool=true)
    if haskey(CACHE, :CURRENCY_LIST)
        return get(CACHE, :CURRENCY_LIST, missing)
    end

    res = _get_current_currency_list(today())
    if convert_to_utf
        df = CSV.read(IOBuffer(decode(res.body, "ISO-8859-1")), DataFrame)
    else
        df = CSV.read(IOBuffer(res.body), DataFrame)
    end

    # nomes_originais = names(df)
    rename!(df, [
        :code,
        :name,
        :symbol,
        :country_code,
        :country_name,
        :type,
        :exclusion_date]
    )
    df = subset(df, :country_code => ByRow(!ismissing))
    
    df.code = passmissing(convert).(Int32, df.code)
    df.name = passmissing(convert).(String, df.name)
    df.symbol = passmissing(convert).(String, df.symbol)
    df.country_code = passmissing(convert).(Int32, df.country_code)
    df.country_name = passmissing(convert).(String, df.country_name)
    df.type = passmissing(convert).(String, df.type)
    df.exclusion_date = passmissing(x -> Date(x, DateFormat("d/m/y"))).(df.exclusion_date)

    df.symbol = map(x -> strip(x, [' ', '\n', '\t']), df.symbol)
    df.name = map(x -> strip(x, [' ', '\n', '\t']), df.name)

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

function getcurrency_info(code::Integer)
    
end
function getcurrency_info(code::String)
    
end
