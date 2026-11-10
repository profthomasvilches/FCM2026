library(shiny)
library(tidyverse)

df_iris <- iris
df_penguins <- palmerpenguins::penguins

df_poke <- read.csv("./www/Pokemon_full.csv")
poke_types <- sort(unique(df_poke$type))


custom_value_box <- function(title, value, showcase = NULL, id = NULL, class = "") {
  div(
    id = id,
    class = paste("custom-value-box", class),
    if (!is.null(showcase)) {
      div(class = "custom-value-box-icon", showcase)
    },
    div(
      class = "custom-value-box-content",
      div(class = "custom-value-box-title", title),
      div(class = "custom-value-box-value", value)
    )
  )
}
