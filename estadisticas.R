# Cargar las bibliotecas necesarias
library(DBI)
library(RSQLite)
library(shiny)
library(shinyWidgets)

# Crear conexión a la base de datos
conn <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

# UI
ui <- fluidPage(
  titlePanel("Registro de Sueño"),
  sidebarLayout(
    sidebarPanel(
      dateInput("fecha", "Fecha:", value = Sys.Date(), format = "yyyy-mm-dd"),
      sliderInput("horas_sueno", "Horas de sueño:", min = 1, max = 15, value = 7),
      sliderInput("despertares", "Número de despertares:", min = 0, max = 15, value = 0),
      selectInput("sensacion", "Sensación:",
                  choices = c("normal", "cansado", "descansado"))
    ),
    mainPanel(
      actionButton("guardar", "Guardar datos"),
      actionButton("ver", "Ver datos guardados"),
      verbatimTextOutput("mensaje"),
      tableOutput("datos_guardados")
    )
  )
)

# Server
server <- function(input, output) {
  observeEvent(input$guardar, {
    # Obtener los datos ingresados por el usuario
    fecha <- as.character(input$fecha)  # Convertir la fecha a formato de texto
    horas_sueno <- input$horas_sueno
    despertares <- input$despertares
    sensacion <- input$sensacion
    
    # Insertar datos en la tabla
    dbExecute(conn, "INSERT INTO estadisticas (fecha, horas_sueno, despertares, sensacion)
                 VALUES (?, ?, ?, ?)",
              params = list(fecha, horas_sueno, despertares, sensacion))
    
    output$mensaje <- renderText({
      "Datos guardados correctamente."
    })
  })
  
  observeEvent(input$ver, {
    # Obtener datos guardados
    query <- "SELECT * FROM estadisticas"
    datos <- dbGetQuery(conn, query)
    output$datos_guardados <- renderTable({
      datos
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
