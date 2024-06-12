library(DBI)
library(shiny)
library(tuber)
library(dplyr)
library(stringr)
library(RSQLite)
library(ggplot2)
library(DBI)
library(DT)

# Autenticación Youtube Data API
yt_oauth(app_id = "SUSTITUIR CREDENCIALES",
         app_secret = "SUSTITUIR CREDENCIALES",
         token = '')

# Conexión con la base de datos
con <- dbConnect(RSQLite::SQLite(), "RUTA DE LA BASE DE DATOS")

actualizarTabla <- function() {
  output$tablaUsuarios <- renderTable({
    # Leer los datos de la base de datos y devolverlos como un data frame
    usuarios <- dbGetQuery(con, "SELECT * FROM usuarios")
    usuarios
  })
}

# Interfaz de Usuario
ui <- fluidPage(
  #Abre en el inicio de sesión
  titlePanel("ASMR Sleep", windowTitle = "Inicio de Sesión"),
  includeCSS("estilo.css"),
  
  tabsetPanel(
    id = "tabs",
    tabPanel("Inicio de sesión",
             fluidRow(
               column(12, align = "center",
                      h1(class = "login-title", "ASMR Sleep"),
                      div(class = "login-container",
                          #Solicita credenciales
                          textInput("email", "Email:"),
                          passwordInput("contrasena", "Contraseña:"),
                          actionButton("login", "Iniciar sesión"),
                          #Mensaje de credenciales correctas/incorrectas
                          p(textOutput("mensaje_login"))
                      )
               )
             )
    ),
    #Pestaña de registro
    tabPanel("Registrarse", titlePanel("Formulario de Usuario"),
             sidebarLayout(
               mainPanel(
                 #Datos solicitados al usuario
                 textInput("nombre", "Nombre"),
                 textInput("apellidos", "Apellidos"),
                 numericInput("edad", "Edad", value = 18, min = 1),
                 selectInput("genero", "Género", choices = c("Masculino", "Femenino", "Prefiero no contestar")),
                 textInput("pais", "País"),
                 selectInput("idioma", "Idioma", choices = c("Español", "English", "Français", "Deutsch")),
                 textInput("usuario", "Usuario"),
                 passwordInput("contrasena", "Contraseña"),
                 passwordInput("contrasena_repetida_input", "Repetir Contraseña"),
                 textInput("email", "Email"),
                 actionButton("guardar", "Guardar")
               ),
               mainPanel(#Panel central en blanco
                 
               )
             )),
    #Pestaña de búsqueda
    tabPanel("Búsqueda",  titlePanel("Búsqueda de YouTube"),
             
             # Panel de búsqueda al lado izquierdo
             sidebarPanel(
               textInput("search_term", "Introduce tu búsqueda:", ""),
               actionButton("search_button", "Buscar"),
               tableOutput("preferences") # Para mostrar las preferencias del usuario
               etiquetas_no_me_gusta <- pref$no_me_gusta
             ),
             
             # Muestra en el centro los resultados de la búsqueda
             mainPanel(
               tableOutput("youtube_results")
             )),
    #Pestaña de preferencias
    tabPanel("Preferencias", titlePanel("Valora los siguientes triggers"),
             
             sidebarLayout(
               sidebarPanel(
                 textInput("email", "Selecciona tus preferencias")
               ),
               
               mainPanel(
                 #muestra al usuario los 10 tipos de triggers para que seleccione
                 lapply(1:10, function(i) {
                   fluidRow(
                     column(12, uiOutput(paste0("video_title_", i))),
                     column(12, uiOutput(paste0("video_", i))),
                     column(12, uiOutput(paste0("dropdown_", i))),
                     hr()
                   )
                 }),
                 fluidRow(
                   #Botón de guardado de preferencias
                   column(12, actionButton("guardar_preferencias", "Guardar Preferencias"))
                 )
               )
             )
    ),
    #Pestaña de estadísticas
    tabPanel("Estadísticas", titlePanel("Registro de Sueño"),
             sidebarLayout(
               #Al lado izquierdo para rellenar datos nuevos
               sidebarPanel(
                 dateInput("fecha", "Fecha:", value = Sys.Date(), format = "dd-mm"), # Cambio de formato de fecha
                 sliderInput("horas_sueno", "Horas de sueño:", min = 1, max = 15, value = 7),
                 sliderInput("despertares", "Número de despertares:", min = 0, max = 15, value = 0),
                 selectInput("sensacion", "Sensación:",
                             choices = c("normal", "cansado", "descansado")),
                 timeInput("hora_apagado", "Hora de apagado de luces:", value = "22:00"),
                 timeInput("hora_encendido", "Hora de encendido de luces:", value = "06:00"),
                 radioButtons("despertar_precoz", "Despertar precoz:", choices = c("Sí", "No"), selected = "No"),
                 sliderInput("latencia_sueno", "Latencia de sueño (min):", min = 0, max = 120, value = 15)
               ),
               #Panel central para guardado de los datos y visualización de las estadísticas
               mainPanel(
                 actionButton("guardar_est", "Guardar datos"),
                 actionButton("ver", "Ver datos guardados"),
                 plotOutput("plot_horas_sueno"),
                 plotOutput("plot_despertares"),
                 plotOutput("plot_sensacion"),
                 plotOutput("plot_hora_apagado"),
                 plotOutput("plot_hora_encendido"),
                 plotOutput("plot_despertar_precoz"),
                 plotOutput("plot_latencia_sueno"),
                 verbatimTextOutput("mensaje"),
                 tableOutput("datos_guardados")
               )
             )
    ),
    #Pestaña de favoritos
    tabPanel("Favoritos", titlePanel("Gestión de videos favoritos"),
             sidebarLayout(
               sidebarPanel(
                 #Modificaciones de la tabla
                 textInput("url", "URL del video:", ""),
                 actionButton("add", "Agregar Video"),
                 br(),
                 textInput("delete_url", "URL a eliminar:", ""),
                 actionButton("delete", "Eliminar Video")
               ),
               mainPanel(
                 #muestra de los videos seleccionados como favoritos
                 DTOutput("videos_table")
               )
             )),
    #Pestaña del administrador
    tabPanel("Administrador", titlePanel("Administrador de Usuarios"),
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
                 actionButton("eliminar", "Eliminar", style = "color: #fff; background-color: #d9534f; border-color: #d43f3a;"),#En rojo para que destaque
                 br(), # Salto de línea
                 actionButton("consultar", "Consultar Usuario")
               ),
               mainPanel(
                 #Muestra la tabla de usuarios
                 DTOutput("usuarios_table")
               )
             ))
  )
)

# Definición del servidor
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
    user_email <- email
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
  
  #Observador para guardar las estadísticas de sueño
  observeEvent(input$guardar_est, {
    # Obtener los datos ingresados por el usuario
    fecha <- format(input$fecha, "%d-%m")  # Convertir la fecha a formato día-mes
    horas_sueno <- input$horas_sueno
    despertares <- input$despertares
    sensacion <- input$sensacion
    hora_apagado <- format(input$hora_apagado, "%H:%M")
    hora_encendido <- format(input$hora_encendido, "%H:%M")
    despertar_precoz <- input$despertar_precoz
    latencia_sueno <- input$latencia_sueno
    
    # Insertar datos en la tabla
    dbExecute(con, "INSERT INTO estadisticas (fecha, horas_sueno, despertares, sensacion, hora_apagado, hora_encendido, despertar_precoz, latencia_sueno)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
              params = list(fecha, horas_sueno, despertares, sensacion, hora_apagado, hora_encendido, despertar_precoz, latencia_sueno))
    
    output$mensaje <- renderText({
      "Datos guardados correctamente."
    })
  })
  
  #Observador para visualizar estadísticas anteriores
  observeEvent(input$ver, {
    # Obtener datos guardados
    query <- "SELECT * FROM estadisticas ORDER BY fecha"  # Ordenar por fecha
    datos <- dbGetQuery(con, query)
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
    
    # Gráfica de Despertar Precoz, de tarta
    output$plot_sensacion <- renderPlot({
      datos %>%
        count(sensacion) %>%
        ggplot(aes(x = "", y = n, fill = factor(sensacion))) +
        geom_bar(width = 1, stat = "identity") +
        coord_polar("y", start = 0) +
        labs(title = "sensacion", fill = "sensacion") +
        theme_void() +
        theme(legend.position = "right")
    })
    
    # Gráfica de Hora de Apagado de Luces, de puntos
    output$plot_hora_apagado <- renderPlot({
      ggplot(datos, aes(x = fecha, y = as.POSIXct(hora_apagado, format = "%H:%M"))) +
        geom_point(color = "purple") +
        labs(title = "Hora de Apagado de Luces", x = "Fecha", y = "Hora de Apagado")
    })
    
    # Gráfica de Hora de Encendido de Luces, de puntos
    output$plot_hora_encendido <- renderPlot({
      ggplot(datos, aes(x = fecha, y = as.POSIXct(hora_encendido, format = "%H:%M"))) +
        geom_point(color = "orange") +
        labs(title = "Hora de Encendido de Luces", x = "Fecha", y = "Hora de Encendido")
    })
    
    # Gráfica de Despertar Precoz, de tarta
    output$plot_despertar_precoz <- renderPlot({
      datos %>%
        count(despertar_precoz) %>%
        ggplot(aes(x = "", y = n, fill = factor(despertar_precoz))) +
        geom_bar(width = 1, stat = "identity") +
        coord_polar("y", start = 0) +
        labs(title = "Despertar Precoz", fill = "Despertar Precoz") +
        theme_void() +
        theme(legend.position = "right")
    })
    
    # Gráfica de Latencia de Sueño
    output$plot_latencia_sueno <- renderPlot({
      ggplot(datos, aes(x = fecha, y = latencia_sueno)) +
        geom_bar(stat = "identity", fill = "blue") +
        labs(title = "Latencia de Sueño", x = "Fecha", y = "Latencia de Sueño (min)")
    })
  })
  
  #Muestra de vídeos para la pestaña de preferencias
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
    
    output[[paste0("video_", i)]] <- renderUI({ #Muestra los videos seleccionados
      yt_id <- video_data[[local_i]]$url
      HTML(paste0('<iframe width="560" height="315" src="https://www.youtube.com/embed/', yt_id, '" frameborder="0" allowfullscreen></iframe>'))
    })
    
    #Botones de selección para cada trigger
    output[[paste0("dropdown_", i)]] <- renderUI({
      selectInput(inputId = paste0("dropdown_", local_i), label = "Selecciona una opción:",
                  choices = c("Seleccione su respuesta","Me gusta", "Neutral", "No me gusta"))
    })
    
    output[[paste0("video_title_", i)]] <- renderUI({
      local_title <- video_data[[local_i]]$title
      HTML(paste0('<p>', local_title, '</p>'))
    })
    
    observeEvent(input[[paste0("dropdown_", local_i)]], {
      guardarRespuesta(input, input$email, video_data[[local_i]]$title, input[[paste0("dropdown_", local_i)]])
    })
  })
  
  #Botón para guardar las respuestas en preferencias
  guardarRespuesta <- function(input, email, titulo, respuesta) {
    existe <- dbGetQuery(con, paste0("SELECT COUNT(*) AS count FROM preferencias WHERE email = '", email, "'"))
    
    if (existe$count == 0) {
      dbExecute(con, paste0("INSERT INTO preferencias (email, `", titulo, "`) VALUES ('", email, "', '", respuesta, "')"))
    } else {
      dbExecute(con, paste0("UPDATE preferencias SET `", titulo, "` = '", respuesta, "' WHERE email = '", email, "'"))
    }
  }
  
  #Mostrar los datos guardados de preferencias
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
  # Definir la salida para la tabla de usuarios
  output$tablaUsuarios <- renderTable({
    # Leer los datos de la base de datos y devolverlos como un data frame
    usuarios <- dbGetQuery(con, "SELECT * FROM usuarios")
    usuarios
  })
  
  # Observador para guardar al al hacer clic en el botón "Guardar"
  observeEvent(input$guardar, {
    # Verificar si las contraseñas coinciden
    if (input$contrasena != input$contrasena_repetida_input) {
      showModal(modalDialog(
        title = "Contraseña incorrecta",
        "Pruebe de nuevo",
        easyClose = TRUE
      ))
      return()
    }else{
      showModal(modalDialog(
        title = "Datos correctos",
        "Nuevo usuario registrado",
        easyClose = TRUE))
    # Si las contraseñas coinciden, insertar los datos en la base de datos
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
    
    # Actualizar la tabla de usuarios
    output$tablaUsuarios <- renderTable({
      # Leer los datos de la base de datos y devolverlos como un data frame
      usuarios <- dbGetQuery(con, "SELECT * FROM usuarios")
      usuarios
    })}
  })
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
    if (user_email == "admin") {
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
    })}
  })
  
  # Observador para abrir la ventana modal de modificación cuando se presiona el botón "Modificar Usuario"
  observeEvent(input$modificar, {
    if (user_email == "admin") {
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
  }})
  
  # Observador para actualizar un usuario cuando se presiona el botón "Actualizar Usuario"
  observeEvent(input$update_user, {
    if (user_email == "admin") {
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
  }})
  
  # Observador para eliminar un usuario cuando se presiona el botón "Eliminar"
  observeEvent(input$eliminar, if (user_email == "admin") {{
    email <- input$email_to_modify
    dbExecute(con, "DELETE FROM usuarios WHERE email = ?", params = email)
    output$usuarios_table <- renderDT({
      datatable(getUsuarios(), escape = FALSE, selection = 'none')
    })
  }})
  
  # Observador para mostrar la información del usuario consultado
  output$user_info <- renderText({
    if (user_email == "admin") {
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
  }})
  
  # Observador para abrir la ventana modal de consulta cuando se presiona el botón "Consultar Usuario"
  observeEvent(input$consultar, {
    showModal(modalDialog(
      id = "consult_modal",
      textOutput("user_info"),
      footer = modalButton("Cerrar")
    ))
  })
  getUsuarios <- function() {
    usuarios <- dbGetQuery(con, "SELECT nombre, apellido, email FROM usuarios")
    usuarios
  }
  # Mostrar la tabla de usuarios inicialmente
  output$usuarios_table <- renderDT({
    datatable(getUsuarios(), escape = FALSE, selection = 'none')
  })
  
 #Observador para modificar la pestaña de favoritos 
  observeEvent(input$add, {
    con <- dbConnect(RSQLite::SQLite(), "RUTA DE LA BASE DE DATOS")
    
    # Extraer el ID del video de la URL
    video_id <- sub(".*v=([^&]*).*", "\\1", input$url)
    
    # Obtener detalles del video
    video_details <- get_video_details(video_id)
    
    # Extraer nombre y etiquetas
    nombre <- video_details$items[[1]]$snippet$title
    etiquetas <- paste(video_details$items[[1]]$snippet$tags, collapse = ", ")
    
    query <- "INSERT OR IGNORE INTO videosfav (usuario, nombre, etiquetas, URL) VALUES (?, ?, ?, ?)"
    dbExecute(con, query, params = list(email, nombre, etiquetas, input$url))
    
    dbDisconnect(con)
  })
  
  #Observador para eliminar videos de la base de datos de favoritos
  observeEvent(input$delete, {
    con <- dbConnect(RSQLite::SQLite(), "RUTA A LA BASE DE DATOS")
    
    query <- "DELETE FROM videosfav WHERE URL = ? AND usuario = ?"
    dbExecute(con, query, params = list(input$delete_url, email))
    
    dbDisconnect(con)
  })
  
  #Mostrar los vídeos favoritos del usuario
  output$videos_table <- renderDT({
    con <- dbConnect(RSQLite::SQLite(), "RUTA A LA BASE DE DATOS")
    data <- dbGetQuery(con, "SELECT nombre, etiquetas, URL FROM videosfav WHERE usuario = email LIMIT 10")
    dbDisconnect(con)
    
    # Convertir las URLs en hipervínculos
    data$URL <- paste0('<a href="', data$URL, '" target="_blank">', data$URL, '</a>')
    
    datatable(data, escape = FALSE, options = list(pageLength = 10))
  })
  
  # Mapear los nombres de las columnas a los nombres deseados para buscar las etiquetas en inglés
  column_names <- c(
    "susurros" = "whisper",
    "scratching" = "scratching",
    "juego_rol" = "roleplay",
    "sonidos_boca" = "mouthsounds",
    "toques" = "touch",
    "susurros_inaudibles" = "inaudible",
    "sonidos_naturales" = "nature",
    "movimientos_lentos" = "slow",
    "masajes" = "massage",
    "visual" = "visual"
  )
  
  # Consulta la base de datos y obtiene las preferencias del usuario
  user_preferences <- reactive({
    # Conexión a la base de datos
    con <- dbConnect(RSQLite::SQLite(), "RUTA A LA BASE DE DATOS")  # Se cambió la ruta del archivo
    query <- "SELECT * FROM preferencias WHERE email = email "
    user_pref <- dbGetQuery(con, query)
    dbDisconnect(con)
    
    # Procesa las preferencias
    me_gusta <- names(user_pref)[which(user_pref == "Me gusta")]
    no_me_gusta <- names(user_pref)[which(user_pref == "No me gusta")]
    
    me_gusta <- column_names[me_gusta]
    no_me_gusta <- column_names[no_me_gusta]
    
    list(me_gusta = me_gusta, no_me_gusta = no_me_gusta)
  })
  
  # Muestra las preferencias del usuario
  output$preferences <- renderTable({
    pref <- user_preferences()
    data.frame(
      Categoría = c(rep("Me gusta", length(pref$me_gusta)), rep("No me gusta", length(pref$no_me_gusta))),
      Preferencias = c(pref$me_gusta, pref$no_me_gusta)
    )
  })
  
  # Realiza la búsqueda en YouTube y muestra los primeros 10 resultados en una tabla
  observeEvent(input$search_button, {
    df <- data.frame()
    counter <- 0
    
    while(nrow(df) < 10) {
      # Realiza la búsqueda
      results <- yt_search(input$search_term, type = "video", max_results = 10)
      
      # Filtra los resultados que tienen etiquetas
      results <- filter(results, str_detect(description, "#\\w+"))
      #Filtra los resultados que tienen etiquetas marcadas como "no me gusta"
      results <- filter(results, !str_detect(description, paste(etiquetas_no_me_gusta, collapse = "|")))
      
      
      # Si hay resultados con etiquetas, se agregan al dataframe
      if(nrow(results) > 0) {
        counter <- counter + nrow(results)
        df <- bind_rows(df, results)
      }
      
      # Si el contador supera 10, sale del bucle
      if(counter >= 10) {
        break
      }
    }
    
    # Seleccionamos solo los primeros 10 resultados
    df <- head(df, 10)
    
    # Dataframe de los resultados a mostrar
    df <- data.frame(
      Título = df$title,
      Etiquetas = sapply(df$description, function(x) {
        hashtags <- str_extract_all(x, "#\\w+")
        if (length(hashtags) > 0) {
          paste(unlist(hashtags), collapse = ", ")
        } else {
          NA
        }
      }),
      URL = sapply(df$video_id, function(x) paste0("https://www.youtube.com/watch?v=", x))
    )
    
    # Muestra la tabla de resultados
    output$youtube_results <- renderTable({
      df
    })
  })
  
}

# Ejecutar la aplicación Shiny
shinyApp(ui, server)
