
# Define a interface do usuário
ui <- fluidPage(
  theme = "custom.css",
  # Título da aplicação
  div(
    class = "header-container",
    h2("Análise Exploratória: Iris e Penguins", class = "titulo-app"),
    img(src = "logo.png", alt = "Logo", class = "logo-app")
  ),

  tabsetPanel(
    type = "tabs",

    # Aba 1: Dataset Iris
    tabPanel(
        title = "Iris",


      # Primeira Linha: Filtros (esquerda) + Gráfico 1 (direita)
      fluidRow(
        column(
            width = 6,
            div(
              width = 6,
            class = "filter-card",
                selectInput(
                inputId = "iris_var1",
                label = "Selecione a Variável X (Iris):",
                choices = names(iris)[1:4],
                selected = "Sepal.Length"
                ),
                selectInput(
                inputId = "iris_var2",
                label = "Selecione a Variável Y (Iris):",
                choices = names(iris)[1:4],
                selected = "Petal.Length"
                ),
                radioButtons( 
                inputId = "radioIris", 
                label = "Opções de Agrupamento:", 
                choices = list( 
                    "Agrupar" = 1, 
                    "Desagrupado" = 2
                ) 
                )
            )
          ),
          column(
            width = 6,
            div(
            class = "plot-card",
            plotOutput(outputId = "histPlotIris")
            )
          )
      ),
      fluidRow(
        column(
            width = 6,
            div(
            class = "plot-card",
            plotOutput(outputId = "histPlotIris2")
            )
        ),
        column(
          width = 6,
          div(
            class = "plot-card",
          plotOutput(outputId = "pontosIris")
          )
        )

      )

      # # Layout em barra lateral com área principal
      # sidebarLayout(
        
        
      #   # Painel principal (Saídas)
      #   mainPanel(
      #     #plotOutput(outputId = "histPlot"),
      #     plotOutput(outputId = "histPlotIris"),
      #     plotOutput(outputId = "histPlotIris2"),
      #     plotOutput(outputId = "pontosIris")
      #   )
      # )
    ),

    # Aba 2: Dataset pinguim
    tabPanel(
        title = "Pinguins",

      # Primeira Linha: Filtros (esquerda) + Gráfico 1 (direita)
      fluidRow(
        column(
            width = 6,
            div(
            class = "filter-card",
                selectInput(
                inputId = "ping_var1",
                label = "Selecione a Variável X (Pinguim):",
                choices = names(df_penguins)[3:6],
                selected = "bill_length_mm"
                ),
                selectInput(
                inputId = "ping_var2",
                label = "Selecione a Variável Y (Pinguim):",
                choices = names(df_penguins)[3:6],
                selected = "bill_length_mm"
                ),
                radioButtons( 
                inputId = "radioPing", 
                label = "Opções de Agrupamento:", 
                choices = list( 
                    "Agrupar" = 1, 
                    "Desagrupado" = 2
                ) 
                )
            )
          ),
          column(
            width = 6,
            div(
            class = "plot-card",
            plotOutput(outputId = "histPlotPing")
            )
          )
      ),
      fluidRow(
        column(
            width = 6,
            div(
            class = "plot-card",
            plotOutput(outputId = "histPlotPing2")
            )
        ),
        column(
          width = 6,
          div(
            class = "plot-card",
          plotOutput(outputId = "pontosPing")
          )
        )

      )

    ),
    tabPanel(
        title = "Pokemons",
        sidebarLayout(
          sidebarPanel(
            selectInput(
              inputId = "poke_type",
              label = "Select the Pokemon type:",
              choices = c("All", poke_types),
              selected = "All"
            ),
            selectizeInput( 
              "selectSecType", 
              label = "Select options below (secondary type):", 
              choices = sort(unique(df_poke$secundary.type)), 
              multiple = TRUE 
            ),
            radioButtons( 
              inputId = "radioPoke", 
              label = "Opções de Agrupamento:", 
              choices = list( 
                  "Agrupar" = 1, 
                  "Desagrupado" = 2
              ) 
            )
          ),
          mainPanel(
            fluidRow(
              column(width = 4, uiOutput("box_n_poke")),
              column(width = 4, uiOutput("box_av_attack")),
              column(width = 4, uiOutput("box_av_def"))
            ),
            div(
              class = "plot-card",
              plotOutput(outputId = "plotPokemon")
            )
          )
        )

    )
    

  )

  
)