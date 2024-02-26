
""" #TODO: Descobrir como fazer DOCSTRING de módulo
O módulo (inserir aqui o nome do módulo) tem como realizar as consultas no site de conversor de moedas do BCB.
"""

#* Created by azeredo-e@GitHub

using CSV, HTTP, DataFrames, StringEncodings, Dates, DataFrames
import Base.@kwdef

const CACHE = #? O que eu boto aqui...?

function _get_current_currency_list(_date, n=0)
    url = "http://www4.bcb.gov.br/Download/fechamento/M$(Dates.format(_date, "yyyymmdd")).csv"

    try
        res = HTTP.request("GET", url)
    catch err
        if isa(err, HTTP.Exceptions.ConnectError)
            if n >= 3
                throw(HTTP.Exceptions.ConnectError(url=url, error="Conexão falhou"))
            end
        end
        return _get_current_currency_list(_date, n+1)
    end
    if r.status == 200
        return res
    else
        return _get_current_currency_list(_date - Day(1), 0)
    end
end


function get_currency_list(convert_to_utf=true)
    if CACHE # Checa se eu já busquei por isso e salva para uso futuro

    end

    res = _get_current_currency_list(today())
    if convert_to_utf
        df = CSV.read(IOBuffer(decode(res.body, "ISO-8859-1")), DataFrame)
    else
        df = CSV.read(IOBuffer(res.body), DataFrame)
    end
    nomes_orig = names(df)
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
    df.exclusion_date = passmissing(x -> Date(x, DateFormat("d/m/y"))).(df.exclusion_date)

end
