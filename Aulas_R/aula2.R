library(tidyverse)

dados <- read.csv("./Aulas_R/Pokemon_full.csv")
dados


#* REGular EXpressions
#* REGEX


grepl("saur", "Venosaur")
grepl("saur", "Charmander")
grepl("saur", c("Venosaur", "Charmander")) %>% any()

grep("saur", c("Venosaur", "Charmander", "Venosaur"))

grepl("saur", "Charmander") # Regex

x <- c("Venosaur", "BulbaSaur")
grepl("[Ss]aur", x) # Regex
grep("[Ss]aur", x) # Regex

x <- c(
  "Amonia",
  "Ferro",
  "Dióxido de enxofre",
  "Dioxido de Enxofre",
  "Manganês",
  "Dióxido  de  Enxofre",
  "dioxido de  Enxofre",
  "dioxidode  Enxofre"
)

# + um ou mais
# * zero ou mais
grepl("[Dd]i[óo]xido *de\\s+[eE]nxofre", x)

gsub("[Dd]i[óo]xido *de\\s+[eE]nxofre", "Dióxido de Enxofre", x)

n <- c("097.765.986-90", "123.765.98-37")
grepl("\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}", n)

grepl(".", c("a", "b", "c", "0", " "))

dados %>% 
filter(grepl("saur", name))


# ? -----------------------------
# ? JOIN




dados <- read.csv("./Aulas_R/Pokemon_full.csv")
dados %>%  head

df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    rename(
        tipo = type
    )


left_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% head


#* left_join
# vai manter os dados que estiverem à esquerda


df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    filter(type != "grass") %>% 
    rename(
        tipo = type
    )


left_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% head

#* right_join


df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    mutate(
        type = ifelse(type == "grass", "THOMAS", type)
    )  %>% 
    rename(
        tipo = type
    )


right_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% tail

#* inner_join
# mantém o que for comum para os dois


df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    mutate(
        type = ifelse(type == "grass", "THOMAS", type)
    )  %>% 
    rename(
        tipo = type
    )


inner_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% head


inner_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% tail


#* full_join
# full join

full_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% head


full_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% tail


# --------------

#! Tomar cuidado com as relações
#! por padrao o R multiplica linhas e
#! houver mais de uma combinação possível


df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    mutate(
        type = ifelse(type == "grass", "fire", type)
    )  %>%
    rename(
        tipo = type
    )


left_join(
    dados, df_summary,
    by = c("type" = "tipo")
) %>% head(10)




# tirando a relacao errada
df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack)) %>% 
    rename(
        tipo = type
    )



left_join(
    dados, df_summary,
    by = c("type" = "tipo"),
    relationship = "many-to-one"
) %>% head(10)


# -----------

bind_rows(dados, dados) %>% nrow



df1 <- dados %>% slice(1:10)
df2 <- dados %>% slice(11:20)


bind_rows(df1, df2)



df1 <- dados %>% slice(1:10) %>% 
select(-speed)

df2 <- dados %>% slice(11:20) %>% 
select(-attack)


bind_rows(df1, df2)



#? GGPLOT

ggplot(dados, aes(x = attack, y = defense, color = type))+
    geom_point()+
    guides(color = guide_legend(ncol = 2, override.aes = list(size = 5, shape = 18)))+
    theme_bw()+
    theme(
        axis.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 14, face = "plain")
    )


plot(dados$attack, dados$defense)




ggplot(dados, aes(x = type, y = defense, color = type))+
    geom_jitter()+
    geom_boxplot(color = "black", alpha = 0.0)+
    #guides(color = guide_legend(ncol = 2, override.aes = list(size = 5, shape = 18)))+
    theme_bw()+
    theme(
        axis.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 14, face = "plain")
    )

dados %>% 
filter(defense > 200)


# explorando camadas

dados %>% 
mutate(
    attack_t = case_when(
        attack < 50 ~ "fraco",
        attack < 100 ~ "normal",
        attack < 150 ~ "fortin",
        TRUE ~ "fortão"
     )
) %>%
arrange(attack) %>%  
ggplot(aes(x = attack, y = defense, color = attack_t))+
    geom_point()+
    #guides(color = guide_legend(ncol = 2, override.aes = list(size = 5, shape = 18)))+
    theme_bw()+
    theme(
        axis.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 14, face = "plain")
    )



# ---------
# grafico com barra de erros


df_summary <- dados %>% 
    group_by(type) %>% 
    summarise(media_type = mean(attack), sd_at = sd(attack))


ggplot(df_summary, aes(x = type, y = media_type, color = type))+
    geom_point()+
    geom_errorbar(aes(ymin = media_type-sd_at, ymax =  media_type+sd_at), width = 0.0)+
    #guides(color = guide_legend(ncol = 2, override.aes = list(size = 5, shape = 18)))+
    labs(x = "Type", y = "Ataque (média\n e desvio padrão)")+
    theme_bw()+
    theme(
        axis.title = element_text(size = 14, face = "bold"),
        axis.text.y = element_text(size = 12, face = "plain"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1.0, size = 12, face = "plain"),
        legend.position = "none"
    )

ggsave("./Aulas_R/outputs/grafico_barras.png", width = 4, height = 3)
