
# Created by azeredo-e@GitHub


using Dates
using HTTP
using JSON

# A função get usa a função _codes para entender o input do usuário
# com isso ela manda para a classe SGSCode para guardar o valor como
# se fosse um struct


#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                                STRUCTS
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

struct SGSCode{S<:AbstractString, N<:Number}
    name::S
    value::N

    function SGSCode(code::Integer)
        new{AbstractString, Number}(string(code), convertToInt32(code))
    end
    function SGSCode(code::Pair)
        new{AbstractString, Number}(code.first, convertToInt32(code.second))
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
    if isa(input, Number)
        return Int32(input)
    elseif isa(input, AbstractString)
        return parse(Int32, input)
    else
        throw(ArgumentError("Input must be a number or string"))
    end
end


function _get_url_payload(code, start_date, end_date, last)
    payload = Dict(:format => "json")
    
    end_date_exists = @isdefined end_date

    if last == 0
        if !(start_date == missing) || !(end_date == missing)
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
    if "Date" in names(df) 
        df.Date = passmissing(x -> Date(x, DateFormat("dd/mm/yyyy"))).(df.Date)
    end
    if "enddate" in names(df) 
        df.enddate = passmissing(x -> Date(x, DateFormat("dd/mm/yyyy"))).(df.enddate)
    end
    #TODO: Implement frequency, maybe create a type or something
    return df
end


"""
    gettimeseries(codes; start=nothing, finish=nothing,
                  last=0, multi=true)

Returns a DataFrame with the SGS time series.

# Args
codes(Number, AbstractString, Tuple{AbstractString, Number}, Array{AbstractString, Number}, Dict{AbstractString, Number}):\\
    The codes for the desired time series, please not that even though any number
    format is accepted, it is converted to an integer.\\
    The codes can be in one of the following formats:\\
    - `Number`: time-series code\\
    - `Tuple`: tuple containing the desired time-series' codes\\
    - `Tuple`: tuple containg the pair ("SeriesName", code)\\
    - `Dict`: Dictionary with the pair ("SeriesName" => code)\\
    When using codes is interesting to define names for the columns to be used in the time-series

start(Number, String...): Any value that can be converted to a date with `Date()` is valid.\\
Start date of the series.

end(Number, String...): Any value that can be converted to a date with `Date()` is valid.\\
End date of the series.

last(Integer): If last is bigger than 0, `start` and `end` are ignored. Return the
last *n* values of the series.

multi(Bool): If true, returns a single series with multiple variable, if false,
    returns a tuple of single variable series

# Returns

`DataFrame`: univariate or multivariate time series when `multi=true`.
`Tuple{DataFrame}`: tuple of univariate time series when `multi=false`.

# Raises
ErrorException: Failed to fetch time-series data.

"""
function gettimeseries(codes; start=nothing, finish=nothing,
                       last=0, multi=true)
    dfs = []

    for code in (SGSCode(i) for i in codes)
        urd = _get_url_payload(code.value, start_date, end_date, last)
        res = HTTP.get(urd[:url]; query=urd[:payload])
        if res.status != 200
            throw(ErrorException("Download error: code = $(code.value)"))
        end
        df = res.body |> String |> JSON.parse |> DataFrame
        df = _format_df(df, code)
        push!(dfs, df)
        if length(dfs) == 1
            return dfs[0]
        else
            if multi
                return innerjoin(df..., on="Date")
            else
                return dfs
            end
        end
    end
end


