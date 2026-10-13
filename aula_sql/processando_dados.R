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
