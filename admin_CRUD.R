library(shiny)
library(DBI)
library(DT)

# Función para conectar a la base de datos SQLite
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

# Función para obtener los usuarios de la base de datos
getUsuarios <- function() {
  usuarios <- dbGetQuery(con, "SELECT * FROM usuarios")
  usuarios
}

# Definir la UI
ui <- fluidPage(
  titlePanel("Administrador de Usuarios"),
  sidebarLayout(
    sidebarPanel(
      # Botones de acción
      actionButton("create", "Crear"),
      br(), # Salto de línea
      # Buscar usuario por email
      textInput("email_to_modify", "Buscar por Email"),
      br(), # Salto de línea
      
      actionButton("modificar", "Modificar Usuario"),
      br(), # Salto de línea
      actionButton("eliminar", "Eliminar", style = "color: #fff; background-color: #d9534f; border-color: #d43f3a;"),
      br(), # Salto de línea
      actionButton("consultar", "Consultar Usuario")
    ),
    mainPanel(
      DTOutput("usuarios_table")
    )
  )
)

# Definir el servidor
server <- function(input, output, session) {
  
  # Observador para abrir la ventana modal de creación cuando se presiona el botón "Crear"
  observeEvent(input$create, {
    showModal(modalDialog(
      id = "create_modal",
      textInput("nombre", "Nombre"),
      textInput("apellido", "Apellidos"),
      numericInput("edad", "Edad", value = NULL),
      textInput("genero", "Género"),
      textInput("pais", "País"),
      textInput("idioma", "Idioma"),
      textInput("usuario", "Usuario"),
      passwordInput("contrasena", "Contraseña"),
      textInput("email", "Email"),
      footer = tagList(
        actionButton("create_user", "Crear Usuario"),
        modalButton("Cancelar")
      )
    ))
  })
  
  # Observador para crear un nuevo usuario cuando se presiona el botón "Crear Usuario"
  observeEvent(input$create_user, {
    # Obtener los datos del formulario
    nuevo_usuario <- c(
      input$nombre,
      input$apellido,
      input$edad,
      input$genero,
      input$pais,
      input$idioma,
      input$usuario,
      input$contrasena,
      input$email
    )
    # Insertar el nuevo usuario en la base de datos
    dbExecute(con, "INSERT INTO usuarios (nombre, apellido, edad, genero, pais, idioma, usuario, contrasena, email) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", params = nuevo_usuario)
    # Cerrar la ventana modal
    removeModal()
    # Actualizar la tabla de usuarios
    output$usuarios_table <- renderDT({
      datatable(getUsuarios(), escape = FALSE, selection = 'none')
    })
  })
  
  # Observador para abrir la ventana modal de modificación cuando se presiona el botón "Modificar Usuario"
  observeEvent(input$modificar, {
    email <- input$email_to_modify
    usuario <- dbGetQuery(con, paste("SELECT * FROM usuarios WHERE email = '", email, "'", sep = ""))
    showModal(modalDialog(
      id = "modify_modal",
      textInput("nombre", "Nombre", value = usuario$nombre),
      textInput("apellido", "Apellidos", value = usuario$apellido),
      numericInput("edad", "Edad", value = usuario$edad),
      textInput("genero", "Género", value = usuario$genero),
      textInput("pais", "País", value = usuario$pais),
      textInput("idioma", "Idioma", value = usuario$idioma),
      textInput("usuario", "Usuario", value = usuario$usuario),
      passwordInput("contrasena", "Contraseña", value = usuario$contrasena),
      textInput("email", "Email", value = usuario$email),
      footer = tagList(
        actionButton("update_user", "Actualizar Usuario"),
        modalButton("Cancelar")
      )
    ))
  })
  
  # Observador para actualizar un usuario cuando se presiona el botón "Actualizar Usuario"
  observeEvent(input$update_user, {
    # Obtener los datos del formulario
    usuario_actualizado <- c(
      input$nombre,
      input$apellido,
      input$edad,
      input$genero,
      input$pais,
      input$idioma,
      input$usuario,
      input$contrasena,
      input$email
    )
    email <- input$email_to_modify
    # Actualizar el usuario en la base de datos
    dbExecute(con, "UPDATE usuarios SET nombre = ?, apellido = ?, edad = ?, genero = ?, pais = ?, idioma = ?, usuario = ?, contrasena = ?, email = ? WHERE email = ?", params = c(usuario_actualizado, email))
    # Cerrar la ventana modal
    removeModal()
    # Actualizar la tabla de usuarios
    output$usuarios_table <- renderDT({
      datatable(getUsuarios(), escape = FALSE, selection = 'none')
    })
  })
  
  # Observador para eliminar un usuario cuando se presiona el botón "Eliminar"
  observeEvent(input$eliminar, {
    email <- input$email_to_modify
    dbExecute(con, "DELETE FROM usuarios WHERE email = ?", params = email)
    output$usuarios_table <- renderDT({
      datatable(getUsuarios(), escape = FALSE, selection = 'none')
    })
  })
  
  # Observador para mostrar la información del usuario consultado
  output$user_info <- renderText({
    email <- input$email_to_modify
    usuario <- dbGetQuery(con, paste("SELECT * FROM usuarios WHERE email = '", email, "'", sep = ""))
    paste("Nombre: ", usuario$nombre, "\n",
          "Apellidos: ", usuario$apellido, "\n",
          "Edad: ", usuario$edad, "\n",
          "Género: ", usuario$genero, "\n",
          "País: ", usuario$pais, "\n",
          "Idioma: ", usuario$idioma, "\n",
          "Usuario: ", usuario$usuario, "\n",
          "Email: ", usuario$email)
  })
  
  # Observador para abrir la ventana modal de consulta cuando se presiona el botón "Consultar Usuario"
  observeEvent(input$consultar, {
    showModal(modalDialog(
      id = "consult_modal",
      textOutput("user_info"),
      footer = modalButton("Cerrar")
    ))
  })
  
  # Mostrar la tabla de usuarios inicialmente
  output$usuarios_table <- renderDT({
    datatable(getUsuarios(), escape = FALSE, selection = 'none')
  })
  
}

# Ejecutar la aplicación Shiny
shinyApp(ui = ui, server = server)
