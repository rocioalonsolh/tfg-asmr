library(shiny)
library(DBI)

con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

getPreferencias <- function() {
  preferencias <- dbGetQuery(con, "SELECT email FROM preferencias")
  preferencias
}

ui <- fluidPage(
  titlePanel("Valora los siguientes triggers"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("email", "Email:")
    ),
    
    mainPanel(
      lapply(1:10, function(i) {
        fluidRow(
          column(12, uiOutput(paste0("video_title_", i))),
          column(12, uiOutput(paste0("video_", i))),
          column(12, uiOutput(paste0("dropdown_", i))),
          hr()
        )
      }),
      fluidRow(
        column(12, actionButton("guardar_preferencias", "Guardar Preferencias y Mostrar Tabla Actualizada"))
      ),
      fluidRow(
        column(12, tableOutput("tabla_preferencias"))
      )
    )
  )
)

server <- function(input, output, session) {
  video_data <- list(
    list(url = "8mF2-ObyCtY", title = "Susurros"),
    list(url = "0S4-F7dkUP0", title = "Scratching"),
    list(url = "t1UMddBRcPs", title = "Juego_rol"),
    list(url = "KP4q7DZhIVk", title = "Sonidos_boca"),
    list(url = "jRc44hjhSb4", title = "Toques"),
    list(url = "-UddUSJiKB0", title = "Susurros_inaudibles"),
    list(url = "59fHDWDhzkY", title = "Sonidos_naturales"),
    list(url = "7wz_eMsN0KA", title = "Movimientos_lentos"),
    list(url = "iNvQrhgyEsI", title = "Masajes"),
    list(url = "wz9HZ2gPHE4", title = "Visual")
  )
  
  lapply(1:10, function(i) {
    local_i <- i
    
    output[[paste0("video_", i)]] <- renderUI({
      yt_id <- video_data[[local_i]]$url
      HTML(paste0('<iframe width="560" height="315" src="https://www.youtube.com/embed/', yt_id, '" frameborder="0" allowfullscreen></iframe>'))
    })
    
    output[[paste0("dropdown_", i)]] <- renderUI({
      selectInput(inputId = paste0("dropdown_", local_i), label = "Selecciona una opción:",
                  choices = c("Me gusta", "Neutral", "No me gusta"))
    })
    
    output[[paste0("video_title_", i)]] <- renderUI({
      local_title <- video_data[[local_i]]$title
      HTML(paste0('<p>', local_title, '</p>'))
    })
    
    observeEvent(input[[paste0("dropdown_", local_i)]], {
      guardarRespuesta(input, input$email, video_data[[local_i]]$title, input[[paste0("dropdown_", local_i)]])
    })
  })
  
  guardarRespuesta <- function(input, email, titulo, respuesta) {
    existe <- dbGetQuery(con, paste0("SELECT COUNT(*) AS count FROM preferencias WHERE email = '", email, "'"))
    
    if (existe$count == 0) {
      dbExecute(con, paste0("INSERT INTO preferencias (email, `", titulo, "`) VALUES ('", email, "', '", respuesta, "')"))
    } else {
      dbExecute(con, paste0("UPDATE preferencias SET `", titulo, "` = '", respuesta, "' WHERE email = '", email, "'"))
    }
  }
  
  output$tabla_preferencias <- renderTable({
    preferencias <- dbGetQuery(con, paste0("SELECT * FROM preferencias WHERE email = '", input$email, "'"))
    preferencias
  })
  
  observeEvent(input$guardar_preferencias, {
    email <- isolate(input$email)
    preferencias <- dbGetQuery(con, paste0("SELECT * FROM preferencias WHERE email = '", email, "'"))
    output$tabla_preferencias <- renderTable({
      preferencias
    })
  })
}

shinyApp(ui = ui, server = server)
