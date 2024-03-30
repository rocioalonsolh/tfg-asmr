# Cargar las librerías necesarias
library(shiny)
library(tuber) # YouTube API
library(dplyr) # for data manipulation
library(stringr) # for string manipulation

# Define la interfaz de usuario de la aplicación Shiny
ui <- fluidPage(
  titlePanel("Búsqueda de YouTube"),
  
  # Sidebar layout with input and output definitions
  sidebarLayout(
    sidebarPanel(
      textInput("search_term", "Introduce tu búsqueda:", ""),
      actionButton("search_button", "Buscar")
    ),
    
    # Show a table of YouTube search results
    mainPanel(
      tableOutput("youtube_results")
    )
  )
)

# Define el servidor
server <- function(input, output) {
  
  # Realiza la búsqueda en YouTube y muestra los primeros 10 resultados en una tabla
  observeEvent(input$search_button, {
    df <- data.frame()
    counter <- 0
    
    while(nrow(df) < 10) {
      # Realiza la búsqueda
      results <- yt_search(input$search_term, type = "video", max_results = 10)
      
      # Filtra los resultados que tienen etiquetas
      results <- filter(results, str_detect(description, "#\\w+"))
      
      # Si hay resultados con etiquetas, los agregamos al dataframe
      if(nrow(results) > 0) {
        counter <- counter + nrow(results)
        df <- bind_rows(df, results)
      }
      
      # Si el contador supera 10, salimos del bucle
      if(counter >= 10) {
        break
      }
    }
    
    # Seleccionamos solo los primeros 10 resultados
    df <- head(df, 10)
    
    # Crea un dataframe con los datos que quieres mostrar
    df <- data.frame(
      Título = df$title,
      Etiquetas = sapply(df$description, function(x) {
        hashtags <- str_extract_all(x, "#\\w+")
        if (length(hashtags) > 0) {
          paste(unlist(hashtags), collapse = ", ")
        } else {
          NA
        }
      }),
      URL = sapply(df$video_id, function(x) paste0("https://www.youtube.com/watch?v=", x))
    )
    
    # Muestra la tabla de resultados
    output$youtube_results <- renderTable({
      df
    })
  })
}

# Ejecuta la aplicación Shiny
shinyApp(ui = ui, server = server)
