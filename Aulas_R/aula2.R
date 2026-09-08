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

# ---------------------------------------------------


df <- dados %>%
  group_by(type) %>% 
  summarise(
    media_h = mean(height),
    media_w = mean(weight)
  ) 

fator <- max(df$media_w)/max(df$media_h)
fator

df$media_h <- df$media_h*fator

df %>% 
  tidyr::pivot_longer(cols = c("media_h", "media_w"), names_to = "Coluna", values_to = "media") %>% 
  ggplot()+
    geom_col(aes(x = type, y = media, color = Coluna, fill = Coluna), position = position_dodge2())+
  scale_y_continuous(
    
    # Features of the first axis
    name = "Média do peso",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis(~./fator, name="Média do altura"),
    expand = c(0,0)
  )+
  labs(x = "Tipo de pokemon")+
  scale_color_brewer(palette = "Set1", labels = c("Média da altura", "Média do peso"), name = "Medida")+
  scale_fill_brewer(palette = "Set1", labels = c("Média da altura", "Média do peso"), name = "Medida")+
  theme_bw()+
  theme(
    axis.title = element_text(size = 18, face = "bold"),
    axis.text.y = element_text(size = 14),
    axis.text.x = element_text(size = 14, angle = 45, hjust = 1.0),
    legend.title = element_text(size = 15, face = "bold")
  )


#! Não fica bom!
df %>% 
  ggplot()+
    geom_col(aes(x = type, y = media_h, color = "Altura", fill = "Altura"), position = position_dodge2())+
    geom_col(aes(x = type, y = media_w, color = "Peso", fill = "Peso"), position = position_dodge2())+
  scale_y_continuous(
    # Features of the first axis
    name = "Média do peso",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis(~./fator, name="Média do altura"),
    expand = c(0,0)
  )+
  labs(x = "Tipo de pokemon")+
  scale_color_brewer(palette = "Set1", labels = c("Média da altura", "Média do peso"), name = "Medida")+
  scale_fill_brewer(palette = "Set1", labels = c("Média da altura", "Média do peso"), name = "Medida")+
  theme_bw()+
  theme(
    axis.title = element_text(size = 18, face = "bold"),
    axis.text.y = element_text(size = 14),
    axis.text.x = element_text(size = 14, angle = 45, hjust = 1.0),
    legend.title = element_text(size = 15, face = "bold")
  )





# ----------------------


dados_clima <- read.csv("./Aulas_R/tabela_clima.csv")
dados_clima

glimpse(dados_clima)

dados_clima$data  <- as.Date(dados_clima$data, "%d-%m-%Y")
dados_clima$data  <- dmy(dados_clima$data)



#? Fazer um painel para cada variável diferente


#* ggarrange do pacote pubr::

#* facet_wrap

dados_clima %>% 
    tidyr::pivot_longer(cols = c("T", "P", "Pluviosidade"), names_to = "Coluna", values_to = "valor") %>% 
ggplot(aes(x = data, y = valor, color = Coluna))+
    geom_point()+
    geom_line()+
    scale_color_manual(values = codigos[c(1,2,7)])+
    facet_wrap(.~Coluna)+
    theme_bw()+
    theme(
        axis.title = element_text(size = 18, face = "bold"),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14, angle = 45, hjust = 1.0),
        legend.title = element_text(size = 15, face = "bold"),
        legend.position = "none"
    )


dados_clima %>% 
    tidyr::pivot_longer(cols = c("T", "P", "Pluviosidade"), names_to = "Coluna", values_to = "valor") %>% 
ggplot(aes(x = data, y = valor, color = Coluna))+
    geom_point()+
    geom_line()+
    scale_color_manual(values = codigos[c(1,2,7)])+
    #facet_wrap(.~Coluna)+
    theme_bw()+
    theme(
        axis.title = element_text(size = 18, face = "bold"),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14, angle = 45, hjust = 1.0),
        legend.title = element_text(size = 15, face = "bold"),
        legend.position = "none"
    )



# -----------------------------
# Dica bonus

codigos <- rcartocolor::carto_pal(12, "Bold")
scales::show_col(codigos)
