library(tidyverse)
library(chromote)
library(rvest)

# library(RSelenium)

# https://quotes.toscrape.com/
# https://books.toscrape.com/
# https://www.scrapethissite.com/pages/



#? explorando o scrap this site

# Cria uma sessão do Chrome
b <- ChromoteSession$new()

# Navega para a página

b$Page$navigate("https://www.scrapethissite.com/pages/simple/")
Sys.sleep(5)  # esperar a página carregar

html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value

# mostrar os primeiros 500 caracteres
cat(substr(html, 1, 500), "...\n")

# 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
page <- read_html(html)

page

html_elements(page, ".country") %>% 
  html_element(".country-name") %>% html_text2()

page %>%
html_elements(".country")


# o map aplica uma função em um vetor
map(1:5, ~ .x/2)

map(1:5, function(x){ x/2 } )

#? fazendo um manualmente

bloquinho <- html_elements(page, ".country")[1]

# No html_text o texto vem "sujo"
bloquinho %>% html_element(".country-name") %>% html_text()

tibble(
    pais      = bloquinho %>% html_element(".country-name") %>% html_text2(),
    capital   = bloquinho %>% html_element(".country-capital") %>% html_text2(),
    populacao = bloquinho %>% html_element(".country-population") %>% html_text2(),
    area      = bloquinho %>% html_element(".country-area") %>% html_text2()
  )


#? Forma moderna equivalente no purrr:
paises_df <- page %>%
  html_elements(".country") %>%
  map(~ tibble(
    pais      = .x %>% html_element(".country-name") %>% html_text2(),
    capital   = .x %>% html_element(".country-capital") %>% html_text2(),
    populacao = .x %>% html_element(".country-population") %>% html_text2(),
    area      = .x %>% html_element(".country-area") %>% html_text2()
  )) %>%
  list_rbind()


#-----------------------------
#? Hockey
#----------------------------

# 1. Fecha a sessão/aba atual do Chrome
b$close()

# 2. Cria uma nova sessão limpa
b <- ChromoteSession$new()

webpage <- "https://www.scrapethissite.com/pages/forms/"

#b$Page$navigate("https://alumni.unesp.br/login")
b$Page$navigate(webpage)
Sys.sleep(2)  # esperar a pág


html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value


# 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
page <- read_html(html)

hrefs <- html_elements(page, ".pagination") %>% 
html_elements("a") %>%
  html_attr("href") %>%
  unique()

# 4. Converte os links relativos em URLs completas
urls_paginas <- url_absolute(hrefs, base = webpage)

url <- urls_paginas[1]
#? fazendo para o primeiro URL
# Navega até a página específica
b$Page$navigate(url)
Sys.sleep(1.5) # Pausa curta para renderizar

# Captura o HTML atualizado da sessão
html_pagina <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value

# Extrai a tabela HTML e converte em data frame
read_html(html_pagina) %>%
  html_element("table.table") %>%
  html_table()


# 3. Loop para navegar, puxar o HTML e extrair a tabela de cada página
lista_times <- map(urls_paginas, function(url) {
  message("Baixando dados de: ", url)
  
  # Navega até a página específica
  b$Page$navigate(url)
  Sys.sleep(1.5) # Pausa curta para renderizar
  
  # Captura o HTML atualizado da sessão
  html_pagina <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  
  # Extrai a tabela HTML e converte em data frame
  read_html(html_pagina) %>%
    html_element("table.table") %>%
    html_table()
})

# 4. Empilha todas as tabelas em um único Data Frame
todos_os_times <- bind_rows(lista_times)


#! Exemplo clicar e digitar

b$Page$navigate(webpage)
Sys.sleep(2)  # esperar a pág

# document.querySelector("#q")

# Digitar em um input via JavaScript
time <- "Toronto"
js_code <- paste0("document.querySelector('#q').value = '", time,"';")

b$Runtime$evaluate("document.querySelector('#q').value = 'Toronto';")

# Clicar em um botão via JavaScript
# document.querySelector("#hockey > div > div.row.search-area > div > form > input.btn.btn-primary")
b$Runtime$evaluate("document.querySelector('#hockey > div > div.row.search-area > div > form > input.btn.btn-primary').click();")


html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value


url_atual <- b$Target$getTargetInfo()$targetInfo$url
print(url_atual)


# 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
page <- read_html(html)


hrefs <- html_elements(page, ".pagination") %>% 
html_elements("a") %>%
  html_attr("href") %>%
  unique()

read_html(html) %>%
    html_element("table.table") %>%
    html_table()


#-----------------------------------------------------
# Extraindo livros
#-----------------------------------------------------




website <-  "https://books.toscrape.com/"

# 1. Fecha a sessão/aba atual do Chrome
b$close()

# Cria uma sessão do Chrome
b <- ChromoteSession$new()

# Navega para a página

b$Page$navigate(website)


html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value


# 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
page <- read_html(html)

hrefs <- html_elements(page, ".product_pod") %>% 
html_element("a") %>% 
  html_attr("href") %>%
  unique()


# 4. Converte os links relativos em URLs completas
urls_paginas <- url_absolute(hrefs, base = website)

url <- urls_paginas[1]
#? fazendo para o primeiro URL
# Navega até a página específica
b$Page$navigate(url)


paginas <- paste0("https://books.toscrape.com/catalogue/page-",1:50,".html")



urls_livros <- map(paginas, function(url){

  # Navega para a página
  message("Baixando dados de: ", url)

  b$Page$navigate(url)
  Sys.sleep(2)

  html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value


  # 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
  page <- read_html(html)

  hrefs <- html_elements(page, ".product_pod") %>% 
  html_element("a") %>% 
    html_attr("href") %>%
    unique()


  # 4. Converte os links relativos em URLs completas
  urls_paginas <- url_absolute(hrefs, base = paste0(website, "/catalogue/"))

  return(urls_paginas)

})


urls_livros <- Reduce(c, urls_livros)

url <- urls_livros[3]

dados <- map(urls_livros[1:10], function(url){


  # Navega para a página
  message("Baixando dados de: ", url)

  b$Page$navigate(url)
  Sys.sleep(5)

  html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value

  # 1. Converte a string HTML obtida no chromote em um documento xml2/rvest
  page <- read_html(html)

  title <- html_elements(page, ".product_main") %>% html_element("h1")%>% html_text2()
  price <- html_elements(page, ".product_main") %>% html_element(".price_color") %>% html_text2()
  stock <- html_elements(page, ".product_main") %>% html_element(".instock") %>% html_text2()
  Rate <- html_elements(page, ".product_main") %>% html_elements(".star-rating") %>%
    html_attr("class") %>%
    str_remove("star-rating") %>%
    str_trim()


  tibble(
    title, price, stock, Rate
  ) %>% 
  mutate(
    rate = case_when(
      Rate == "One" ~ 1,
      Rate == "Two" ~ 2,
      Rate == "Three" ~ 3,
      Rate == "Four" ~ 4,
      Rate == "Five" ~ 5,
      TRUE ~ NA_integer_,
    )
  ) %>% select(-Rate)
})


dados %>% list_rbind()



#!!! GAMBIARRA

url <- urls_livros[1]

urls_livros <- map(
  urls_livros, ~paste0(gsub("\\.com/.*", "", .x),
".com/catalogue/",
gsub(".*\\.com/","", .x))
) %>% Reduce(c, .)



##
# document.querySelector("#\\32 014")
