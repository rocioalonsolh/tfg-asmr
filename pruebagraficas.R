# Cargar las bibliotecas necesarias
library(DBI)
library(RSQLite)
library(shiny)
library(shinyWidgets)
library(ggplot2)

# Crear conexión a la base de datos
conn <- dbConnect(RSQLite::SQLite(), "C:\\Users\\rocy1\\OneDrive\\Escritorio\\TFG\\usuarios.db")

# UI
ui <- fluidPage(
  titlePanel("Registro de Sueño"),
  sidebarLayout(
    sidebarPanel(
      dateInput("fecha", "Fecha:", value = Sys.Date(), format = "dd-mm"), # Cambio de formato de fecha
      sliderInput("horas_sueno", "Horas de sueño:", min = 1, max = 15, value = 7),
      sliderInput("despertares", "Número de despertares:", min = 0, max = 15, value = 0),
      selectInput("sensacion", "Sensación:",
                  choices = c("normal", "cansado", "descansado"))
    ),
    mainPanel(
      actionButton("guardar", "Guardar datos"),
      actionButton("ver", "Ver datos guardados"),
      plotOutput("plot_horas_sueno"),
      plotOutput("plot_despertares"),
      plotOutput("plot_sensacion"),
      verbatimTextOutput("mensaje"),
      tableOutput("datos_guardados")
    )
  )
)

# Server
server <- function(input, output) {
  observeEvent(input$guardar, {
    # Obtener los datos ingresados por el usuario
    fecha <- format(input$fecha, "%d-%m")  # Convertir la fecha a formato día-mes
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
    query <- "SELECT * FROM estadisticas ORDER BY fecha"  # Ordenar por fecha
    datos <- dbGetQuery(conn, query)
    output$datos_guardados <- renderTable({
      datos
    })
    
    # Gráfica de Horas de Sueño
    output$plot_horas_sueno <- renderPlot({
      ggplot(datos, aes(x = fecha, y = horas_sueno)) +
        geom_bar(stat = "identity", fill = "pink") +  # Gráfico de barras
        labs(title = "Horas de Sueño", x = "Fecha", y = "Horas de Sueño")
    })
    
    # Gráfica de Despertares
    output$plot_despertares <- renderPlot({
      ggplot(datos, aes(x = fecha, y = despertares)) +
        geom_bar(stat = "identity", fill = "skyblue") +  # Gráfico de barras
        labs(title = "Número de Despertares", x = "Fecha", y = "Número de Despertares")
    })
    
    # Gráfica de Estado de Ánimo
    output$plot_sensacion <- renderPlot({
      ggplot(datos, aes(x = fecha, y = sensacion)) +
        geom_bar(stat = "identity", fill = "lightgreen") +  # Gráfico de barras
        labs(title = "Estado de Ánimo", x = "Fecha", y = "Estado de Ánimo")
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
