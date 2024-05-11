library(DBI)
library(shiny)
library(tuber)
library(dplyr)
library(stringr)
library(RSQLite)
library(ggplot2)  # Se agregó para utilizar ggplot



# Crear una base de datos SQLite para este ejemplo
con <- dbConnect(RSQLite::SQLite(), "C:/Users/Rocío/Desktop/TFG/TFG/bbdd/usuarios.db")  # Se cambió la ruta del archivo

# Define la interfaz de usuario
ui <- fluidPage(
  titlePanel("Inicio de Sesión", windowTitle = "Inicio de Sesión"),
  includeCSS("estilo.css"),
  
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
                          p(textOutput("mensaje_login"))
                      )
               )
             )
    ),
    tabPanel("Búsqueda"),
    tabPanel("Preferencias", titlePanel("Valora los siguientes triggers"),
             
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
                   column(12, actionButton("guardar_preferencias", "Guardar Preferencias"))
                 )
               )
             )
    ),
    tabPanel("Estadísticas", titlePanel("Registro de Sueño"),
             sidebarLayout(
               sidebarPanel(
                 dateInput("fecha", "Fecha:", value = Sys.Date(), format = "dd-mm"),
                 sliderInput("horas_sueno", "Horas de sueño:", min = 1, max = 15, value = 7),
                 sliderInput("despertares", "Número de despertares:", min = 0, max = 15, value = 0),
                 selectInput("sensacion", "Sensación:",
                             choices = c("normal", "cansado", "descansado")),
                 actionButton("guardar", "Guardar datos"),
                 actionButton("ver", "Ver datos guardados")
               ),
               mainPanel(
                 verbatimTextOutput("mensaje"),
                 tableOutput("datos_guardados"),
                 plotOutput("plot_horas_sueno"),
                 plotOutput("plot_despertares"),
                 plotOutput("plot_sensacion")
               )
             )
    ),
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
      output$mensaje_login <- renderText(paste("Inicio de sesión exitoso, hola", nombre_usuario))
    } else {
      output$mensaje_login <- renderText("Credenciales no válidas. Por favor, inténtalo de nuevo.")
    }
  })
  
  # Observador para guardar los datos de estadísticas
  observeEvent(input$guardar, {
    email <- input$email  # Obtén el correo electrónico del usuario autenticado
    fecha <- as.character(input$fecha)
    horas_sueno <- input$horas_sueno
    despertares <- input$despertares
    sensacion <- input$sensacion
    
    dbExecute(con, "INSERT INTO estadisticas (email, fecha, horas_sueno, despertares, sensacion)
               VALUES (?, ?, ?, ?, ?)",
              params = list(email, fecha, horas_sueno, despertares, sensacion))
    
    output$mensaje <- renderText({
      "Datos guardados correctamente."
    })
  })
  
  # Observador para ver los datos de estadísticas
  observeEvent(input$ver, {
    email <- input$email  # Obtén el correo electrónico del usuario autenticado
    query <- sprintf("SELECT * FROM estadisticas WHERE email='%s' ORDER BY fecha", email)
    datos <- dbGetQuery(con, query)
    output$datos_guardados <- renderTable({
      datos
    })
    
    output$plot_horas_sueno <- renderPlot({
      ggplot(datos, aes(x = fecha, y = horas_sueno)) +
        geom_bar(stat = "identity", fill = "pink") +
        labs(title = "Horas de Sueño", x = "Fecha", y = "Horas de Sueño")
    })
    
    output$plot_despertares <- renderPlot({
      ggplot(datos, aes(x = fecha, y = despertares)) +
        geom_bar(stat = "identity", fill = "skyblue") +
        labs(title = "Número de Despertares", x = "Fecha", y = "Número de Despertares")
    })
    
    output$plot_sensacion <- renderPlot({
      ggplot(datos, aes(x = fecha, y = sensacion)) +
        geom_bar(stat = "identity", fill = "lightgreen") +
        labs(title = "Estado de Ánimo", x = "Fecha", y = "Estado de Ánimo")
    })
  })
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

# Ejecutar la aplicación Shiny
shinyApp(ui, server)