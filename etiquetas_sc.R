#install.packages("tuber")
library(tuber) # youtube API
library(magrittr) # Pipes %>%, %T>% and equals(), extract().
library(tidyverse) # all tidyverse packages
library(purrr) # package for iterating/extracting data

# use the youtube oauth 
yt_oauth(app_id = "",
         app_secret = "",
         token = '')

# Realizar la búsqueda
results <- yt_search("asmr")

# Obtener los primeros 10 resultados
first_10_results <- head(results, 10)

# Mostrar los primeros 10 resultados
print(first_10_results)

# Extraer palabras precedidas por "#" en la columna "description"
results$hashtags <- str_extract_all(results$description, "#\\w+")

# Filtrar vectores que no tienen hashtags
valid_hashtags <- results$hashtags[sapply(results$hashtags, length) > 0]

# Imprimir el resultado
print(valid_hashtags)

