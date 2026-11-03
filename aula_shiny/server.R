library(shiny)

df_penguins <- palmerpenguins::penguins
df_iris <- iris

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
  
}
