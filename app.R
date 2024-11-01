# app.R
library(shiny)

# Run the application 
shinyApp(ui = source("ui.R")$value, server = source("server.R")$value)
