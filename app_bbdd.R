# Cargar paquetes
library(shiny)
library(RSQLite)

# Conectar a la base de datos SQLite
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")
dbBegin(con)
# Crear la tabla si no existe
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT,
    apellido TEXT,
    edad INTEGER,
    genero TEXT,
    pais TEXT,
    idioma TEXT,
    usuario TEXT,
    contrasena TEXT,
    email TEXT
  )
")

# Definir la interfaz de usuario
ui <- fluidPage(
  titlePanel("Formulario de Usuario"),
  sidebarLayout(
    sidebarPanel(
      textInput("nombre", "Nombre"),
      textInput("apellido", "Apellido"),
      numericInput("edad", "Edad", value = 18, min = 1),
      selectInput("genero", "Género", c("Masculino", "Femenino", "Prefiero no decirlo")),
      textInput("pais", "País"),
      selectInput("idioma", "Idioma", c("Español", "English", "Français", "Deutsch")),
      textInput("usuario", "Usuario"),
      passwordInput("contrasena", "Contraseña"),
      passwordInput("contrasena2", "Repetir Contraseña"),
      textInput("email", "Email"),
      actionButton("guardar", "Guardar"),
      textOutput("mensajeError")
    ),
    mainPanel(
      tableOutput("tablaUsuarios")
    )
  )
)

# Definir el servidor
server <- function(input, output, session) {
  
  # Función para insertar datos en la base de datos
  insertarDatos <- function() {
    if (input$contrasena == input$contrasena2) {
      dbExecute(
        con,
        "INSERT INTO usuarios (nombre, apellido, edad, genero, pais, idioma, usuario, contrasena, email) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        params = list(
          input$nombre, input$apellido, input$edad, input$genero,
          input$pais, input$idioma, input$usuario, input$contrasena, input$email
        )
      )
      output$mensajeError <- renderText("Usuario registrado exitosamente.")
    } else {
      output$mensajeError <- renderText("Las contraseñas no coinciden. Inténtelo de nuevo.")
    }
  }
  
  # Evento al hacer clic en el botón "Guardar"
  observeEvent(input$guardar, {
    insertarDatos()
    actualizarTabla()
  })
  
  # Función para actualizar la tabla de usuarios
  actualizarTabla <- function() {
    output$tablaUsuarios <- renderTable({
      dbGetQuery(con, "SELECT * FROM usuarios")
    })
  }
  
  # Inicializar la tabla al inicio de la aplicación
  actualizarTabla()
}

# Lanzar la aplicación Shiny
shinyApp(ui, server)

dbDisconnect(con)
