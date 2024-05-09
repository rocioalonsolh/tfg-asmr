library(shiny)
library(DBI)
library(RSQLite)

# Crear una base de datos SQLite para este ejemplo
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

# Define la interfaz de usuario
ui <- fluidPage(
  titlePanel("Inicio de Sesión", windowTitle = "Inicio de Sesión"),
  includeCSS("estilo.css"),  # Enlace al archivo CSS externo
  
  # Pestañas para mostrar el contenido después de iniciar sesión
  tabsetPanel(
    id = "tabs",
    tabPanel("Inicio de sesión",
             fluidRow(
               column(12, align = "center",
                      h1(class = "login-title", "ASMR Sleep"),
                      div(class = "login-container",
                          textInput("email", "Email:"),
                          passwordInput("contrasena", "Contraseña:"),
                          actionButton("login", "Iniciar sesión"),
                          p(textOutput("mensaje"))
                      )
               )
             ),
    ),
    tabPanel("Búsqueda"),
    tabPanel("Preferencias"),
    tabPanel("Estadísticas", titlePanel("Registro de Sueño"),
             sidebarLayout(
               sidebarPanel(
                 dateInput("fecha", "Fecha:", value = Sys.Date(), format = "dd-mm"),
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
             )),
    tabPanel("Historial")
  )
)

# Define el servidor
server <- function(input, output, session) {
  
  # Función para validar las credenciales
  validar_credenciales <- function(email, contrasena) {
    query <- sprintf("SELECT nombre FROM usuarios WHERE email='%s' AND contrasena='%s'", email, contrasena)
    result <- dbGetQuery(con, query)
    if (nrow(result) == 1) {
      return(result[[1]])
    } else {
      return(NULL)
    }
  }
  
  # Observador para el botón de inicio de sesión
  observeEvent(input$login, {
    email <- input$email
    contrasena <- input$contrasena
    
    nombre_usuario <- validar_credenciales(email, contrasena)
    
    if (!is.null(nombre_usuario)) {
      # Si las credenciales son válidas, mostrar las pestañas después de iniciar sesión
      output$mensaje <- renderText(paste("Inicio de sesión exitoso, hola", nombre_usuario))
      
    } else {
      # Si las credenciales no son válidas, mostrar un mensaje de error
      output$mensaje <- renderText("Credenciales no válidas. Por favor, inténtalo de nuevo.")
    }
  })
}

# Ejecutar la aplicación Shiny
shinyApp(ui, server)
