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
    # Realiza la búsqueda
    results <- yt_search(input$search_term)
    
    # Obtiene los primeros 10 resultados
    first_10_results <- head(results, 10)
    
    # Imprimir longitudes de los vectores para identificar el problema
    print(length(first_10_results$title))
    print(length(first_10_results$description))
    print(length(first_10_results$publishedAt))
    print(length(first_10_results$video_id))
    
    # Crea un dataframe con los datos que quieres mostrar
    df <- data.frame(
      Título = first_10_results$title,
      Etiquetas = sapply(first_10_results$description, function(x) {
        hashtags <- str_extract_all(x, "#\\w+")
        if (length(hashtags) > 0) {
          paste(unlist(hashtags), collapse = ", ")
        } else {
          NA
        }
      }),
      URL = sapply(first_10_results$video_id, function(x) paste0("https://www.youtube.com/watch?v=", x))
    )
    
    # Rellenar filas sin hashtags con NA
    df$Etiquetas[df$Etiquetas == ""] <- NA
    
    # Muestra la tabla de resultados
    output$youtube_results <- renderTable({
      df
    })
  })
}

# Ejecuta la aplicación Shiny
shinyApp(ui = ui, server = server)
