
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
"""
function gettimeseries(codes; start=nothing, finish=nothing,
                       last=0, multi=true, freq=nothing)
    dfs = []

    for code in _codes(codes)

    end
end


