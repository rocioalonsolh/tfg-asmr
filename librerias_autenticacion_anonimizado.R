#install.packages("tuber")
library(tuber) # youtube API
library(magrittr) # Pipes %>%, %T>% and equals(), extract().
library(tidyverse) # all tidyverse packages
library(purrr) # package for iterating/extracting data
# use the youtube oauth 
yt_oauth(app_id = "Sustituir por ID de cliente",
         app_secret = "Sustituir por secreto de cliente",
         token = '')