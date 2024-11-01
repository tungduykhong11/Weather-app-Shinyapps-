# ui.R
library(shiny)
library(leaflet)
library(shinydashboard)
library(plotly)

# UI 
ui <- dashboardPage(
  dashboardHeader(title = "Interactive Weather App"),
  dashboardSidebar(sidebarMenu(
    menuItem("Current Weather", tabName = "weather"),
    menuItem("Forecast", tabName = "forecast")
  )),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    tabItems(
      tabItem(tabName = "weather",
              fluidRow(
          
                column(width = 3,  
                       box(width = NULL, title = "Current Weather", status = "primary", solidHeader = TRUE,
                           h4(textOutput("location")),
                           h5(textOutput("date")),
                           tags$hr(),
                           h4("Current Temperature:"),
                           h3(textOutput("temperature")),
                           tags$hr(),
                           h4("Feels Like:"),
                           h3(textOutput("feels_like")),
                           tags$hr(),
                           h4("Humidity:"),
                           h3(textOutput("humidity")),
                           tags$hr(),
                           h4("Weather Condition:"),
                           h3(textOutput("weather_condition")),
                           tags$hr(),
                           h4("Wind Speed:"),
                           h3(textOutput("wind_speed")),
                           tags$hr(),
                           uiOutput("weather_image") 
                       )
                ),
               
                column(width = 9, 
                       box(width = NULL, title = "Map", leafletOutput("map"), class = 'map-container')
                )
              )
      ),
      tabItem(tabName = "forecast",
              textOutput("location_"),
              selectInput(
                "feature",
                "Select Feature:",
                list(
                  "temp",
                  "feels_like",
                  "temp_min",
                  "temp_max",
                  "pressure",
                  "sea_level",
                  "grnd_level",
                  "humidity",
                  "speed",
                  "deg",
                  "gust"
                )
              ),
              box(
                title = "Sample Line Chart",
                plotlyOutput("line_chart")
              )
      )
    )
  )
)
