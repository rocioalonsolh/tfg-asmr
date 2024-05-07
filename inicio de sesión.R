library(shiny)
library(DBI)
library(RSQLite)

# Crear una base de datos SQLite para este ejemplo
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

# Define la interfaz de usuario
ui <- fluidPage(
  titlePanel(" ", windowTitle = "Inicio de Sesión"),
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css?family=Nunito"),
    
    tags$style(HTML("
      body {
        font-family: 'Nunito', sans-serif; /* Cambio de la tipografía a Nunito */
        background-color: #e6f3ff; /* Azul pastel */
      }
      .login-container {
        max-width: 400px;
        margin: 0 auto;
        padding: 20px;
        border: 1px solid #ccc;
        border-radius: 5px;
        background-color: white;
      }
      .login-title {
        text-align: center;
        font-size: 30px;
        margin-bottom: 20px;
        color: #333; /* Color de texto oscuro */
      }
    "))
  ),
  div(class = "login-container",
      h1(class = "login-title", "ASMR Sleep"),
      textInput("email", "Email:"),
      passwordInput("contrasena", "Contraseña:"),
      actionButton("login", "Iniciar sesión"),
      p(textOutput("mensaje")),
      uiOutput("redirect")
  )
)

# Define el servidor
server <- function(input, output, session) {
  
  # Función para validar las credenciales
  validar_credenciales <- function(email, contrasena) {
    query <- sprintf("SELECT COUNT(*) FROM usuarios WHERE email='%s' AND contrasena='%s'", email, contrasena)
    result <- dbGetQuery(con, query)
    return(result[[1]] == 1)
  }
  
  # Observador para el botón de inicio de sesión
  observeEvent(input$login, {
    email <- input$email
    contrasena <- input$contrasena
    
    if (validar_credenciales(email, contrasena)) {
      # Si las credenciales son válidas, redirigir a una nueva página en blanco
      output$redirect <- renderUI({
        tags$script(HTML('window.location.href = "nueva_pagina_en_blanco.html";'))
      })
    } else {
      # Si las credenciales no son válidas, mostrar un mensaje de error
      output$mensaje <- renderText("Credenciales no válidas. Por favor, inténtalo de nuevo.")
    }
  })
}

# Ejecutar la aplicación Shiny
shinyApp(ui, server)