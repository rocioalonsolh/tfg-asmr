library(DBI)

# Especifica la ruta de tu base de datos SQLite
db_path <- "ruta/tu/base/de/datos.db"

# Crea la conexión a la base de datos
con <- dbConnect(RSQLite::SQLite(), db_path)

# Crea una tabla para almacenar los datos de usuario
dbExecute(con, "CREATE TABLE IF NOT EXISTS usuarios (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre TEXT,
                apellidos TEXT,
                edad INTEGER,
                genero TEXT,
                pais TEXT,
                idioma TEXT,
                usuario TEXT,
                contrasena TEXT,
                email TEXT)")

# Cierra la conexión
dbDisconnect(con)
