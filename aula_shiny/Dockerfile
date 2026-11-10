# 1. Imagem base com R e Shiny pré-instalados
FROM rocker/shiny:4.5.2

# 2. Instalar dependências de sistema do Linux (necessárias para pacotes como dplyr, ssl, etc.)
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libuv1-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Definir diretório de trabalho dentro do container
WORKDIR /app

# 4. Copiar arquivos do renv para instalar pacotes com cache otimizado
COPY renv.lock .
COPY renv/activate.R renv/
COPY .Rprofile .

# 5. Restaurar as dependências exatas do R via renv
RUN R -e "install.packages('renv'); renv::restore()"

# 6. Copiar o restante do seu código (ui.R, server.R, global.R, pasta www/, etc.)
COPY . /app

# 7. Expor a porta padrão do Shiny
EXPOSE 3839

# 8. Comando para iniciar o Shiny App escutando em todas as interfaces de rede
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3839)"]