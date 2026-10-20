library(tidyverse)
library(RPostgreSQL)
library(odbc)
library(DBI)

# install.packages(c("RPostgreSQL", "odbc", "DBI"))
install.packages("RPostgres")


con <- dbConnect(RPostgres::Postgres(),
                 dbname = "database",
                 host = "localhost",
                 port = 5432,
                 user = "postgres",
                 password = "1234")


# Lista os objetos dentro do schema "projetinho"
DBI::dbListObjects(con, DBI::Id(schema = "projetinho"))


#? Processando dados

dados <- read.csv2("./tabela9514.csv")
glimpse(dados)


#? alimentar tabela de municipios

df <- dados %>% 
select(Cod = 1, Mun = 2)


glimpse(df)


df <- df %>% 
mutate(
    Cod = as.character(Cod),
    Cod6 = str_extract(Cod, "\\w{6}")
) %>% 
select(
    nome_mun = Mun, codigo_ibge = Cod, codigo_ibge_6 = Cod6
)


odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "ref_mun"), value = df,
  row.names = FALSE, append = TRUE
)


DBI::dbGetQuery(con, 'SELECT * FROM "projetinho.ref_mun"') %>% glimpse


#? GRUPOS DE IDADE

v <- dados %>% names()


data.frame(grupo_idade = v[4:24]) %>% 
    mutate(
        grupo_idade = gsub("X", "", grupo_idade),
        grupo_idade = str_replace_all(grupo_idade, "\\.", " ")
    ) %>% 
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "ref_grupo_idade"), value = .,
  row.names = FALSE, append = TRUE
)


#? Processando os dados propriamente

dados %>% glimpse()


df <- dados %>% 
select(-c(2,3)) %>% 
mutate(
    across(c(-1), as.integer),
    Cód. = as.character(Cód.),
    across(where(is.numeric), ~ replace_na(.x, 0))
)  %>% 
rename(Cod = Cód.) %>% 
pivot_longer(c(-1), names_to = "grupo_idade", values_to = "N") %>% 
    mutate(
        sexo = ifelse(grepl("1$", grupo_idade), "F", "M"),
        grupo_idade = gsub("X", "", grupo_idade),
        grupo_idade = str_replace_all(grupo_idade, "\\.", " "),
        grupo_idade = gsub("1$", "", grupo_idade),
        grupo_idade = trimws(grupo_idade, "both")
    )

df %>% tail()

df_ref_mun <- DBI::dbGetQuery(con, 'SELECT id_mun, codigo_ibge FROM projetinho.ref_mun') 
df_ref_grupo_idade <- DBI::dbGetQuery(con, 'SELECT id_gi, grupo_idade FROM projetinho.ref_grupo_idade') 

df %>% 
left_join(
    df_ref_mun, by = c("Cod" = "codigo_ibge")
) %>% 
select(-1)%>% 
left_join(
    df_ref_grupo_idade
) %>% 
select(-1) %>% 
rename(mun_idade_id = id_mun, grupo_idade_id = id_gi, n = N) %>% 
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "tab_idade"), value = .,
  row.names = FALSE, append = TRUE
)


# ----------------------------------------------------------
# Raça/Cor
# ----------------------------------------------------------
DBI::Id(schema = "projetinho", table = "tab_idade")

DBI::dbGetQuery(con, 'SELECT * FROM "projetinho"."ref_mun"') %>% glimpse

dados <- read.csv2("./tabela9606.csv")

glimpse(dados)


# --- 
#? Alimentando a tabela de referencia raça cor

dados %>% 
select(raca = 3) %>%  unique %>% 
filter(raca != "Total") %>% 
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "ref_raca"), value = .,
  row.names = FALSE, append = TRUE
)


#! FUNCAO

trocar_id <- function(con, df, X, Z, tabY){
  
  tab <- odbc::dbGetQuery(
    con, paste0("SELECT ", X,",",Z,  " FROM ", tabY,";")
  )
  
  df_novo <- df %>% 
    left_join(tab, by = X) %>% 
    select(-paste0(X))
    
  
  return(df_novo)
}



#!-------------------------

dados <- dados %>% 
select(codigo_ibge = 1, raca = 3, n = 4) %>%
mutate(
    n = as.integer(n),
    n = replace_na(n, 0)
) %>% 
filter(raca != "Total")

dados %>% glimpse()

dados <- dados %>% mutate(codigo_ibge = as.character(codigo_ibge))

trocar_id(con, dados, "raca", "id_raca", '"projetinho"."ref_raca"') %>%
trocar_id(con, ., "codigo_ibge", "id_mun", '"projetinho"."ref_mun"') %>% 
rename(raca_id = id_raca, mun_raca_id = id_mun) %>%
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "tab_raca"), value = .,
  row.names = FALSE, append = TRUE
)


# ----------------------------------------------------
# Renda
# --------------------------------------------------------

dados <- read.csv2("./tabela10296.csv")
glimpse(dados)


dados <- dados %>% 
select(codigo_ibge = 1, renda = 3, n = 4) %>%
mutate(
    n = as.integer(n),
    n = replace_na(n, 0)
) %>% 
filter(renda != "Total")

glimpse(dados)


#* Tabela de referencia

dados %>% 
select(renda) %>%  unique %>% 
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "ref_renda"), value = .,
  row.names = FALSE, append = TRUE
)

dados %>% 
mutate(
    codigo_ibge = as.character(codigo_ibge)
) %>% 
trocar_id(con, ., "codigo_ibge", "id_mun", '"projetinho"."ref_mun"') %>% 
trocar_id(con, ., "renda", "id_renda", '"projetinho"."ref_renda"') %>% 
rename(renda_id = id_renda, mun_renda_id = id_mun) %>% 
odbc::dbWriteTable(
  con, name = DBI::Id(schema = "projetinho", table = "tab_renda"), value = .,
  row.names = FALSE, append = TRUE
)




# ------------------------------------------------------
# -----------------------------------------------------






df <- DBI::dbGetQuery(con, 'WITH tabela_idade AS (
    SELECT mun_idade_id, SUM(n) AS soma_idade FROM "projetinho"."tab_idade" WHERE grupo_idade_id > 12 GROUP BY mun_idade_id
),
tabela_renda AS (
    SELECT mun_renda_id, SUM(n) AS soma_renda FROM "projetinho"."tab_renda"
	WHERE renda_id = 12 OR renda_id BETWEEN 1 AND 4
	GROUP BY mun_renda_id
),
tabela_total AS (
    SELECT mun_idade_id as mun_total_id, SUM(n) AS soma_total FROM "projetinho"."tab_idade" GROUP BY mun_idade_id
)
SELECT mun_idade_id AS mun_id, soma_idade, soma_renda, soma_total FROM tabela_idade INNER JOIN tabela_renda ON
mun_idade_id = mun_renda_id INNER JOIN tabela_total ON mun_idade_id = mun_total_id;') 

glimpse(df)

df %>% 
mutate(
    p_idade = soma_idade/soma_total,
    p_renda = soma_renda/soma_total
) %>% 
ggplot()+
geom_point(aes(x = p_idade, y = p_renda))



df %>% 
mutate(
    p_idade = soma_idade/soma_total,
    p_renda = soma_renda/soma_total
) %>% 
ggplot()+
geom_point(aes(x = soma_idade, y = soma_renda)) + 
scale_x_continuous(limits = c(0, 150000))+
scale_y_continuous(limits = c(0, 250000))
