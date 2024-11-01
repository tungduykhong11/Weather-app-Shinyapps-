# server.R
library(shiny)
library(leaflet)
library(jsonlite)
library(plotly)

# Function to get information of current weather from OpenWeatherMap
get_weather_info <- function(lat, lon) {
  api_key <- "d076ef1cee22c7c2a00ad9afcf232eb5"
  API_call <- "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$name)) {
    return(NULL)  
  }
  
  location <- json$name
  temp <- jsonmainmaintemp - 273.2
  feels_like <- jsonmainmainfeels_like - 273.2
  humidity <- jsonmainmainhumidity
  weather_condition <- jsonweatherweatherdescription
  visibility <- json$visibility
  wind_speed <- jsonwindwindspeed
  
  list(
    Location = location,
    Temperature = temp,
    Feels_like = feels_like,
    Humidity = humidity,
    WeatherCondition = weather_condition,
    Visibility = visibility,
    Wind_speed = wind_speed
  )
}

# Function to select the appropriate weather image
get_weather_image <- function(condition) {
  if (grepl("cloud", condition)) {
    return("clouds.jpg")
  } else if (grepl("clear", condition)) {
    return("clear.jpg")
  } else if (grepl("rain", condition)) {
    return("rain.jpg")
  } else if (grepl("snow", condition)) {
    return("snow.jpg")
  } else {
    return("default.jpg")  
  }
}

get_forecast <- function(lat, lon) {
  api_key <- "d076ef1cee22c7c2a00ad9afcf232eb5"
  API_call <- "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$list)) {
    return(NULL)  
  }
  
  df <- data.frame(
    Time = jsonlistlistdt_txt,
    Location = jsoncitycityname,
    feels_like = json$list$main$feels_like - 273.2,
    temp_min = json$list$main$temp_min - 273.2,
    temp_max = json$list$main$temp_max - 273.2,
    pressure = json$list$main$pressure,
    sea_level = json$list$main$sea_level,
    grnd_level = json$list$main$grnd_level,
    humidity = json$list$main$humidity,
    temp_kf = json$list$main$temp_kf,
    temp = json$list$main$temp - 273.2,
    id = sapply(json$list$weather, function(entry) entry$id),
    main = sapply(json$list$weather, function(entry) entry$main),
    icon = sapply(json$list$weather, function(entry) entry$icon),
    weather_conditions = sapply(json$list$weather, function(entry) entry$description),
    speed = json$list$wind$speed,
    deg = json$list$wind$deg,
    gust = json$list$wind$gust,
    stringsAsFactors = FALSE 
  )
  
  return(df)
}

# Server
server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 105.8341598, lat = 21.0277644, zoom = 10)
  })
  
  click <- NULL
  weather_info <- NULL
  
  observeEvent(input$map_click, {
    click <<- input$map_click
    weather_info <<- get_weather_info(clicklat,clicklat, clicklng)
    
    if (is.null(weather_info)) {
      return()  
    }
    
    outputlocation <- renderText({ weather_infolocation <- renderText({ weather_infoLocation })
    outputhumidity <- renderText({ paste(weather_infohumidity <- renderText({ paste(weather_infoHumidity, "%") })
    outputtemperature <- renderText({ paste(weather_infotemperature <- renderText({ paste(weather_infoTemperature, "°C") })
    outputfeels_like <- renderText({ paste(weather_infofeels_like <- renderText({ paste(weather_infoFeels_like, "°C") })
    outputweather_condition <- renderText({ weather_infoweather_condition <- renderText({ weather_infoWeatherCondition })
    outputvisibility <- renderText({ weather_infovisibility <- renderText({ weather_infoVisibility })
    outputwind_speed <- renderText({ weather_infowind_speed <- renderText({ weather_infoWind_speed })
    
    output$weather_image <- renderUI({
      img(src = get_weather_image(weather_info$WeatherCondition), height = "200px", width = "300px")
    })
  })
  
  observeEvent(input$feature, {
    output$location_ <- renderText({ paste('Location: ', weather_info$Location) })
    
    # set default
    default_lon <- 105.8341598
    default_lat <- 21.0277644
    data <- get_forecast(default_lat, default_lon)
    
    if (!is.null(click)) {
      data <- get_forecast(clicklat,clicklat, clicklng)
    }
    
    if (is.null(data)) {
      output$line_chart <- renderText({"Nothing!!"})
      return()
    }
    
    output$line_chart <- renderPlotly({
      feature_data <- data[, c("Time", input$feature)]
      if (!all(c("Time", input$feature) %in% colnames(data))) {
        return(NULL)  
      }
      
      plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], 
              type = 'scatter', mode = 'lines+markers', name = input$feature) %>%
        layout(title = "Sample Line Chart", xaxis = list(title = "Time"), yaxis = list(title = input$feature))
    })
  })
}
