#install.packages("pdftools")

#library(pdftools)

arquivo <- "./Aulas_R/Peru - Evento 4732.pdf"

conteudo <- pdftools::pdf_text(arquivo)

conteudo[1]
conteudo[2]

# quebrando as linhas
conteudo <- str_split(conteudo, "\\n")

# acessar elemento da lista
conteudo[[3]]

# juntando todas as linhas
conteudo <- Reduce(c, conteudo)

pos_out <- grep("OUTBREAK\\s+REFERENCE", conteudo)


pos_out <- c(pos_out, length(conteudo)+1)

i = 1 # indice do outbreak



run_conteudo_pdf <- function(x, conteudo, pos_out){
    i <- x
    print(i)
    conteudo_out <- conteudo[pos_out[i]:(pos_out[i+1]-1)]


    # extraindo a data de inicio
    pos_start <- grep("START\\s+DATE", conteudo_out)
    pos_secadm <- grep("SECOND\\s+ADMINISTRATIVE", conteudo_out)

    linha_start <- conteudo_out[pos_start]

    localizacao <- str_locate(linha_start, "START\\s+DATE")

    localizacao_out <- str_locate(linha_start, "OUTBREAK\\s+REFERENCE")

    # encontra a localização aproximada do start date
    loc_start <- (localizacao_out[2]+localizacao[,1])/2

    # extrai a data
    for(j in (pos_start+1):(pos_secadm-1)){
        # subsstring -> corta a minha string
        # trimws -> joga fora espaços laterais
        linha_s <- trimws(substring(conteudo_out[j], loc_start), "left")

        # rastreia a data
        if(str_detect(linha_s, "^\\d{4}/\\d{2}/\\d{2}")){
            start_date <- str_extract(linha_s,"^\\d{4}/\\d{2}/\\d{2}")
            break
        }else{
            start_date <- NULL
        }
        
    }

    if(is.null(start_date)){
        error(paste("nao achei start date na posicao", pos_out[i], "no arquivo", arquivo))
    }




    # Location

    pos_loc <- grep("LOCATION\\s+Latitude", conteudo_out)
    pos_afec <- grep("AFFECTED\\s+POPULATION\\s+DESCRIPTION", conteudo_out)

    linha <- conteudo_out[pos_loc]

    localizacao <- str_locate(linha, "LOCATION\\s+Latitude")

    localizacao_lat <- str_locate(linha, "Latitude")


    loc <- c()
    jj  <- 1
    for(j in (pos_loc+1):(pos_afec-1)){
        linha_s <- substring(conteudo_out[j], localizacao[,1], localizacao_lat[,1]-1)

        linha_s <- str_remove_all(linha_s, "-?\\d+\\.\\d+\\s*,?\\s*-?(\\d+)?\\.?(\\d+)?")
        linha_s <- trimws(linha_s, "both")
        loc[jj] <- linha_s
        jj <- jj+1
    }

    location <- paste(loc, collapse = " ")




    pos_loc <- grep("LOCATION\\s+Latitude", conteudo_out)
    pos_afec <- grep("AFFECTED\\s+POPULATION\\s+DESCRIPTION", conteudo_out)

    linha <- conteudo_out[pos_loc]

    localizacao <- str_locate(linha, "LOCATION\\s+Latitude")

    localizacao_lat <- str_locate(linha, "Latitude")


    # roda as linhas entre a linha com LOCATION e a linha com AFFECTED POPULATION
    for(j in (pos_loc+1):(pos_afec-1)){
        linha_s <- conteudo_out[j]
        # Detecta a longitude e latitude
        if(str_detect(linha_s, "-?\\d+\\.\\d+\\s*,\\s*-?\\d+\\.\\d+")){
            lat_long <- str_extract(linha_s,"-?\\d+\\.\\d+\\s*,\\s*-?\\d+\\.\\d+")
            break
        }else{
            lat_long <- NULL
        }
    }

    if(is.null(lat_long)){
        error(paste("nao achei lat long na posicao", pos_out[i], "no arquivo", arquivo))
    }

    # joga espaço branco fora
    lat_long <- trimws(lat_long, "both")

    lat <- str_extract(lat_long, ".*(?=,)")
    long <- str_extract(lat_long, "(?<=,).*")

    lat <- as.numeric(lat)
    long <- as.numeric(long)

    info <- data.frame(id = 1, start_date = start_date, lat = lat, long = long, loc = location)




    ##### Tabela


    l_inicio <- grep("Species\\s+Wildlife", conteudo_out)
    l_final <- grep("METHOD\\s+OF\\s+DIAGNOSTIC", conteudo_out)

    conteudo_tabela  <- conteudo_out[l_inicio:l_final-1]

    # indice_tabela <- indice_x[l_inicio:l_final-1]

    pos_new <- grep("NEW", conteudo_tabela)

    # achar as especies

    pos_finais_specie <- c(pos_new-1, length(conteudo_tabela))[-1]

    especies <- c()
    for(i in 1:length(pos_new)){
        v <- c()
        jj <- 1
        j <- pos_new[i]
        linha <- conteudo_tabela[j]
        loc <- str_locate(linha, "NEW")[1] #localizano o NEW
        for(j in pos_new[i]:pos_finais_specie[i]){
            linha <- conteudo_tabela[j]
            v[jj] <- substring(linha, 1, loc-1) # corto a linha no meio
            jj <- jj+1
        }
        v <- trimws(v, "both")
        if(grepl("-$", v[1])){
            especies[i] <- paste0(v, collapse = "")
        }else{
            especies[i] <- paste0(v, collapse = " ")
        }
        
    }


    #####
    pos_total <- grep("TOTAL", conteudo_tabela)

    linhas_total <- trimws(str_extract(conteudo_tabela[pos_total], "(?<=TOTAL).*"), "both")
    linhas_total <- str_split(linhas_total, "\\s+")
    v1 <- lapply(linhas_total, function(x) suppressWarnings(as.integer(x)))

    #indice_total <- indice_tabela[pos_total]

    if(length(v1) == 1){
        v1 <- t(as.matrix(Reduce(rbind, v1)))
    }else{
        v1 <- as.matrix(Reduce(rbind, v1))
    }


    data_f <- data.frame(especies, v1, id = 1)


    data_f <- full_join(data_f, info, by = "id")  %>% 
        select(-id) %>% 
        rename(
            species = especies,
            susceptible = X1, cases = X2,
            Deaths = X3, `Killed and Disposed of` = X4,
            `Slaughtered/Killed for commercial use` = X5,
            Vaccinated = X6, `START DATE`= start_date,
            LOCATION = loc, Latitude = lat, Longitude = long
        )


    return(data_f)
}


dados <- lapply(1:(length(pos_out)-1), run_conteudo_pdf, conteudo = conteudo, pos_out = pos_out)


dados <- Reduce(rbind, dados)

openxlsx::write.xlsx(dados, "./Aulas_R/outputs/resultado_extracao.xlsx")
