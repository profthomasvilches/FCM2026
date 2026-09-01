# ! asdasdasdasd
# ? asdasdassdasdasd
# * sadfasdfasdfasdf
# TODO sadfsdfasdfasdf


#install.packages("tidyverse")

library(tidyverse)


# ------------------------------

a = 2
a
a = 3
a

a <- 2

a == 2

a/2



x  <- c(10, 20, 30)
2*x
x+10

y <- rnorm(100)
y

hist(y)
plot(x)




# ---------------------


dados <- read.csv("./Aulas_R/Pokemon_full.csv")
dados

glimpse(dados)
dplyr::glimpse(dados)

dados$name

dados$attack/dados$defense

dados$IMC <- dados$weight/dados$height^2

glimpse(dados)


#? Selecionar colunas usando DPLYR
select(dados, name, attack)

teste1 <- select(dados, name)
teste1$name
#? PULL
teste2 <- pull(dados, name)
teste2

#? Filtrar dados
filter(dados, height > 10)

#? criar colunas
mutate(dados, rate_atdef = attack/defense)

#? resumir dados
summarise(dados, media_at = mean(attack), sd_at = sd(attack))

#* teste - calcular a media do ataque e o desvio padrao
#* apenas para pokemons com mais de 10 de altura

df <- filter(dados, height > 10)

#? resumir dados
summarise(df, media_at = mean(attack), sd_at = sd(attack))

#! PIPE %>% - dplyr, R Base |>

dados %>% 
filter(height > 10) %>%
  summarise(media_at = mean(attack), sd_at = sd(attack))

#* criar uma coluna que é soma de ataque e defesa

dados %>% 
  mutate(
    soma_ad = attack+defense,
    soma2 = height+weight
  ) %>% 
  select(soma_ad, soma2)



dados %>% 
  pull(attack) %>% max()

dados %>% 
  select(attack) %>% max()

dados %>% 
  pull(attack) |> max


# -----------------

dados %>% 
  group_by(type) %>% 
  summarise(media_at = mean(attack), sd_at = sd(attack))


dados %>% 
  group_by(type) %>% 
  mutate(media_at = mean(attack)) %>%
  filter(attack > media_at) %>% 
  select(-media_at)



dados %>% 
  group_by(type) %>% 
  filter(attack > mean(attack)) 



#? rowwise

#? A função mutate e outras do pacote dplyr trabalham diretamente com as colunas
#? como se fossem operações de vetor

dados %>%
    mutate(
        name2 = paste(name, " - NOVO")
    ) %>% head

#? Na prática, o dplyr faz isso:
paste(dados$name, "- NOVO")

dados %>%  pull(name) %>% 
paste("- NOVO")

#? o que significa que a função PRECISA aceitar um vetor

#? Imagine que você queira criar uma função que testa se o valor de uma coluna
#? na observação i é maior ou menor que um dado valor e executa uma certa ação.

f <- function(x){
    if(x <= 15){ #? no caso, o valor é 300
        return("Executei essa ação")
    }else{

        return("Executei Aquela ação")
    }
}

x1 <- c(30, 16, 20, 3)
f(x1)

#! O código abaixo não funciona
dados %>%
    mutate(
        nova_var = f(height)
    ) %>%
        select(height, nova_var) %>% head(30)

#* O código abaixo funciona
#TODO
dados %>%
rowwise() %>%
    mutate(
        nova_var = f(height)
    ) %>%
        select(height, nova_var) %>% head(30) %>% 
  ungroup() %>%
    mutate(
        nova_var2 = mean(height)
    )

# ? O codigo abaixo sai agrupado por linha

dados %>%
rowwise() %>%
    mutate(
        nova_var = f(height),
        media = mean(height)
    ) %>% 
  ungroup() %>%
    mutate(
        nova_var2 = mean(height)
    )%>% head(30) %>%
        select(height, nova_var, media, nova_var2) 
