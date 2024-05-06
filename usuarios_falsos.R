# Cargar paquetes
library(shiny)
library(RSQLite)
library(charlatan)

# Conectar a la base de datos SQLite
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")

# Crear la tabla si no existe
dbExecute(con, "
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT,
    apellidos TEXT,
    edad INTEGER,
    genero TEXT,
    pais TEXT,
    idioma TEXT,
    usuario TEXT,
    contrasena TEXT,
    email TEXT
  )
")

# Función para insertar datos en la base de datos
insertarDatos <- function(nombre, apellido, edad, genero, pais, idioma, usuario, contrasena, email) {
  dbExecute(
    con,
    "INSERT INTO usuarios (nombre, apellido, edad, genero, pais, idioma, usuario, contrasena, email) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
    params = list(nombre, apellido, edad, genero, pais, idioma, usuario, contrasena, email)
  )
}
#usuarios falsos generados por chatgpt
usuarios_falsos <- data.frame(
  nombre = c("Juan", "María", "Pedro", "Ana", "Carlos", "Laura", "Pablo", "Elena", "Luis", "Carmen",
             "Sergio", "Isabel", "Miguel", "Raquel", "Javier", "Silvia", "Alberto", "Natalia", "Diego", "Adriana"),
  apellido = c("Gómez", "Martínez", "López", "Fernández", "Rodríguez", "Sánchez", "González", "Pérez", "Díaz", "Muñoz",
                "Hernández", "Torres", "Jiménez", "Ruiz", "Alonso", "Molina", "Vega", "García", "Navarro", "Gutiérrez"),
  edad = c(25, 30, 22, 35, 28, 33, 26, 40, 29, 27, 31, 36, 23, 38, 32, 34, 39, 26, 29, 37),
  genero = c("Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino",
             "Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino", "Masculino", "Femenino"),
  pais = c("España", "Argentina", "México", "Colombia", "Chile", "Perú", "Venezuela", "Ecuador", "Uruguay", "Paraguay",
           "Bolivia", "Brasil", "Guatemala", "Panamá", "Costa Rica", "Honduras", "El Salvador", "Nicaragua", "Cuba", "Puerto Rico"),
  idioma = c("Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español",
             "Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español", "Español"),
  usuario = c("juan123", "maria456", "pedro789", "ana321", "carlos654", "laura987", "pablo1234", "elena567", "luis890", "carmen123",
              "sergio456", "isabel789", "miguel321", "raquel654", "javier987", "silvia1234", "alberto567", "natalia890", "diego123", "adriana456"),
  contrasena = c("claveJuan", "claveMaria", "clavePedro", "claveAna", "claveCarlos", "claveLaura", "clavePablo", "claveElena", "claveLuis", "claveCarmen",
                 "claveSergio", "claveIsabel", "claveMiguel", "claveRaquel", "claveJavier", "claveSilvia", "claveAlberto", "claveNatalia", "claveDiego", "claveAdriana"),
  email = c("juan@gmail.com", "maria@hotmail.com", "pedro@yahoo.com", "ana@gmail.com", "carlos@hotmail.com", 
            "laura@gmail.com", "pablo@yahoo.com", "elena@hotmail.com", "luis@gmail.com", "carmen@yahoo.com",
            "sergio@gmail.com", "isabel@hotmail.com", "miguel@yahoo.com", "raquel@gmail.com", "javier@hotmail.com",
            "silvia@yahoo.com", "alberto@gmail.com", "natalia@hotmail.com", "diego@yahoo.com", "adriana@gmail.com")
)

# Insertar usuarios falsos en la base de datos
for (i in 1:20) {
  mapply(
    function(nombre, apellidos, edad, genero, pais, idioma, usuario, contrasena, email) {
      insertarDatos(
        as.character(nombre),
        as.character(apellidos),
        as.integer(edad),
        as.character(genero),
        as.character(pais),
        as.character(idioma),
        as.character(usuario),
        as.character(contrasena),
        as.character(email)
      )
    },
    usuarios_falsos$nombre,
    usuarios_falsos$apellidos,
    usuarios_falsos$edad,
    usuarios_falsos$genero,
    usuarios_falsos$pais,
    usuarios_falsos$idioma,
    usuarios_falsos$usuario,
    usuarios_falsos$contrasena,
    usuarios_falsos$email
  )
}


# Definir la interfaz de usuario
ui <- fluidPage(
  titlePanel("Formulario de Usuario"),
  sidebarLayout(
    sidebarPanel(
      textInput("nombre", "Nombre"),
      textInput("apellidos", "Apellidos"),
      numericInput("edad", "Edad", value = 18, min = 1),
      textInput("genero", "Género"),
      textInput("pais", "País"),
      textInput("idioma", "Idioma"),
      textInput("usuario", "Usuario"),
      passwordInput("contrasena", "Contraseña"),
      textInput("email", "Email"),
      actionButton("guardar", "Guardar")
    ),
    mainPanel(
      tableOutput("tablaUsuarios")
    )
  )
)

# Definir el servidor
server <- function(input, output, session) {
  
  # Evento al hacer clic en el botón "Guardar"
  observeEvent(input$guardar, {
    insertarDatos(
      as.character(input$nombre),
      as.character(input$apellidos),
      as.integer(input$edad),
      as.character(input$genero),
      as.character(input$pais),
      as.character(input$idioma),
      as.character(input$usuario),
      as.character(input$contrasena),
      as.character(input$email)
    )
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
runApp(appDir = shinyApp(ui = ui, server = server), port = 8888)

