directory_path <- "data/"
if (!dir.exists(directory_path)) {
  dir.create(directory_path)
}

readr::write_csv(x = as.data.frame(SarahLavenderRaw), 
                 file = paste0(directory_path, 
                               base::noquote(lubridate::today()),
                               "-SarahLavenderRaw.csv"))
#example
# export SarahLavenderRaw
readr::write_csv(x = as.data.frame(SarahLavenderRaw), 
                 file = paste0("data/", 
                               base::noquote(lubridate::today()),
                               "-SarahLavenderRaw.csv"))


# export SarahLavenderRaw
readr::write_csv(x = as.data.frame(SarahLavenderAllStatsRaw), 
                 path = paste0("data/", 
                               base::noquote(lubridate::today()),
                               "-SarahLavenderAllStatsRaw.csv"))

# verify
fs::dir_ls("data", regexp = "Sarah")