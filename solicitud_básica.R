# Definir la URL de la solicitud
queryUrl <- "https://www.googleapis.com/youtube/analytics/v1/reports"

# Realizar la solicitud a la API de YouTube Analytics
response <- GET(
  queryUrl,
  add_headers("Authorization" = paste("Bearer", token$access_token)),
  query = list(
    ids = "channel==@OzleyASMR",  # Reemplaza con el ID del canal
    metrics = "views,estimatedMinutesWatched",
    dimensions = NULL,
    sort = NULL,
    maxResults = 10,
    filters = NULL,
    startDate = "2020-01-01",
    endDate = as.character(Sys.Date()),
    currency = NULL,
    startIndex = NULL,
    includeHistoricalChannelData = NULL
  )
)

# Imprimir la respuesta
print(content(response, "text"))
