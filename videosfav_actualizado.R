# Definir la UI
ui <- fluidPage(
  includeCSS("estilo.css"),
  titlePanel("Gestión de videos favoritos"),
  sidebarLayout(
    sidebarPanel(
      textInput("email", "Email:", ""),
      textInput("url", "URL del video:", ""),
      actionButton("add", "Agregar Video"),
      br(),
      textInput("delete_url", "URL a eliminar:", ""),
      actionButton("delete", "Eliminar Video")
    ),
    mainPanel(
      tableOutput("videos_table")
    )
  )
)

# Definir el server
server <- function(input, output, session) {
  
  observeEvent(input$add, {
    con <- dbConnect(RSQLite::SQLite(), "videos.db")
    
    # Extraer el ID del video de la URL
    video_id <- sub(".*v=([^&]*).*", "\\1", input$url)
    
    # Obtener detalles del video
    video_details <- get_video_details(video_id)
    
    # Extraer nombre y etiquetas
    nombre <- video_details$items[[1]]$snippet$title
    etiquetas <- paste(video_details$items[[1]]$snippet$tags, collapse = ", ")
    
    query <- "INSERT OR IGNORE INTO videosfav (usuario, nombre, etiquetas, URL) VALUES (?, ?, ?, ?)"
    dbExecute(con, query, params = list(input$email, nombre, etiquetas, input$url))
    
    dbDisconnect(con)
  })
  
  observeEvent(input$delete, {
    con <- dbConnect(RSQLite::SQLite(), "C:\\Users\\rocy1\\OneDrive\\Escritorio\\TFG\\usuarios.db")
    
    query <- "DELETE FROM videosfav WHERE URL = ?"
    dbExecute(con, query, params = list(input$delete_url))
    
    dbDisconnect(con)
  })
  
  output$videos_table <- renderTable({
    con <- dbConnect(RSQLite::SQLite(), "C:\\Users\\rocy1\\OneDrive\\Escritorio\\TFG\\usuarios.db")
    data <- dbGetQuery(con, "SELECT * FROM videosfav LIMIT 10")
    dbDisconnect(con)
    data
  })
}

# Ejecutar la aplicación Shiny
shinyApp(ui = ui, server = server)
