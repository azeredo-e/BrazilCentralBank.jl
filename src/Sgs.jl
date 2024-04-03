
# Created by azeredo-e@GitHub


using Dates

# A função get usa a função _codes para entender o input do usuário
# com isso ela manda para a classe SGSCode para guardar o valor como
# se fosse um struct



#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#*                              FUNCTIONS
#* #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-


function _get_url_payload(code, start_date, end_date, last)
    payload = Dict(:format => "json")
    
    end_date_exists = @isdefined end_date

    if last == 0
        if !(start_date == missing) || (end_date == missing)
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


"""
function gettimeseries(codes; start=nothing, finish=nothing,
                       last=0, multi=true, freq=nothing)
    dfs = []

    for code in _codes(codes)

    end
end


