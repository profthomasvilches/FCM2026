
# Define a lógica do servidor
server <- function(input, output, session) {
  
  # # Renderiza o gráfico com base no input do slider
  # output$histPlot <- renderPlot({
    
  #   # Desenha o histograma
  #   hist(
  #     df_penguins$bill_length_mm, 
  #     breaks = input$num_obs,
  #     col = 'darkgray', 
  #     border = 'white',
  #     main = "Histograma de Dados Pinguins",
  #     xlab = "Valores"
  #   )
  # })
  output$histPlotIris <- renderPlot({
    
    if(input$radioIris == 2){
      # Desenha o histograma
      df_iris %>% 
        select(.data[[input$iris_var1]]) %>% 
        ggplot(aes(x = .data[[input$iris_var1]])) +
        geom_histogram(alpha = 0.8, color = "darkgreen", fill = "darkgreen")+
        theme_bw()
    }else{
      df_iris %>% 
        select(.data[[input$iris_var1]], Species) %>% 
        ggplot(aes(x = .data[[input$iris_var1]], color = Species, fill = Species)) +
        geom_histogram(alpha = 0.8)+
        theme_bw()
    }
    
  })
  output$histPlotIris2 <- renderPlot({
    df_iris %>% 
        select(.data[[input$iris_var2]]) %>% 
        ggplot(aes(x = .data[[input$iris_var2]])) +
        geom_histogram(alpha = 0.8, color = "darkgreen", fill = "darkgreen")+
        theme_bw()
  })
  output$pontosIris <- renderPlot({

    if(input$radioIris == 2){
      df_iris %>% 
        select(.data[[input$iris_var1]], .data[[input$iris_var2]]) %>% 
        ggplot(aes(x = .data[[input$iris_var1]], y = .data[[input$iris_var2]])) +
        geom_point(color = "darkgreen", fill = "darkgreen")+
        theme_bw()
    }else{
        df_iris %>% 
        select(.data[[input$iris_var1]], .data[[input$iris_var2]], Species) %>% 
        ggplot(aes(x = .data[[input$iris_var1]], y = .data[[input$iris_var2]], color = Species)) +
        geom_point()+
        theme_bw()
    }
    
  })



  output$histPlotPing <- renderPlot({
    
    # Desenha o histograma
    hist(
      df_penguins[[input$ping_var1]],
      col = 'darkgray', 
      border = 'white',
      main = "Histograma de Dados Iris",
      xlab = "Valores"
    )
  })
  output$histPlotPing2 <- renderPlot({
    
    # Desenha o histograma
    hist(
      df_penguins[[input$ping_var2]],
      col = 'darkgray', 
      border = 'white',
      main = "Histograma de Dados Iris",
      xlab = "Valores"
    )
  })
  output$pontosPing <- renderPlot({
    
    # Desenha o histograma
    plot(
      df_penguins[[input$ping_var1]],
      df_penguins[[input$ping_var2]],
      main = "Scatter plot",
      xlab = input$ping_var1,
      ylab = input$ping_var2
    )
  })


  # Observa quando o input poke_type é alterado
  observeEvent(input$poke_type, {
    
    # 1. Filtra as opções de tipo secundário conforme a escolha do tipo primário
    if (input$poke_type == "All") {
      # Se for "All", obtém todos os tipos secundários únicos
      novas_opcoes <- sort(unique(df_poke$secundary.type))
    } else {
      # Filtra o dataframe para o tipo selecionado e pega os secundários correspondentes
      novas_opcoes <- df_poke %>%
        filter(type == input$poke_type) %>% # Ajuste 'type' para o nome da sua coluna de tipo primário
        pull(secundary.type) %>%
        unique() %>%
        sort()
    }
    
    # 2. Atualiza o input selectSecType na interface do usuário (UI)
    updateSelectizeInput(
      session = session,
      inputId = "selectSecType",
      choices = novas_opcoes,
      selected = NULL # Reseta a seleção atual para não manter opções inválidas
    )
  })
  

  # 1. Dataframe reativo filtrado
  df_poke_filtrado <- reactive({
    dados <- df_poke
    
    # Filtra por tipo primário
    if (!is.null(input$poke_type) && input$poke_type != "All") {
      dados <- dados %>% filter(type == input$poke_type)
    }
    
    # Filtra por tipo secundário (se houver seleção)
    if (!is.null(input$selectSecType) && length(input$selectSecType) > 0) {
      dados <- dados %>% filter(secundary.type %in% input$selectSecType)
    }
    
    dados
  })



  # 2. Renderização do Value Box: Número de Pokémons
  output$box_n_poke <- renderUI({
    dados <- df_poke_filtrado()
    total <- length(unique(dados$name))
    
    custom_value_box(
      id = "n_poke",
      class = "value_box_poke",
      title = "Number of Pokemons",
      value = total,
      showcase = icon("spaghetti-monster-flying")
      #theme = value_box_theme(bg = "#2d5a27", fg = "#ffffff")
    )
  })

  # 3. Renderização do Value Box: Média de Ataque
  output$box_av_attack <- renderUI({
    dados <- df_poke_filtrado()
    media_attack <- if (nrow(dados) > 0) round(mean(dados$attack, na.rm = TRUE), 1) else 0
    
    custom_value_box(
      id = "av_attack",
      class = "value_box_poke",
      title = "Average attack",
      value = media_attack,
      showcase = icon("hand-fist")
      #theme = value_box_theme(bg = "#2d5a27", fg = "#ffffff")
    )
  })

  # 4. Renderização do Value Box: Média de Defesa
  output$box_av_def <- renderUI({
    dados <- df_poke_filtrado()
    media_def <- if (nrow(dados) > 0) round(mean(dados$defense, na.rm = TRUE), 1) else 0
    
    custom_value_box(
      id = "av_def",
      class = "value_box_poke",
      title = "Average defense",
      value = media_def,
      showcase = icon("shield")
      #theme = value_box_theme(bg = "#2d5a27", fg = "#ffffff")
    )
  })

  output$plotPokemon <- renderPlot({
    dados <- df_poke_filtrado()
    if(!input$radioPoke == 2){
      dados %>% 
       ggplot(aes(x = attack, y = defense)) +
        geom_point(color = "darkgreen", fill = "darkgreen")+
        theme_bw()
    }else{
      dados %>% 
      ggplot(aes(x = attack, y = defense, color = secundary.type)) +
        geom_point()+
        theme_bw()
    }
   

  })

  
}
