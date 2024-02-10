sa_lav_ids <- base::as.vector(SarahLavenderRaw$contentDetails.videoId)
dplyr::glimpse(sa_lav_ids)
# Function to scrape stats for all vids
get_all_stats <- function(id) {
  tuber::get_stats(video_id = id)
} 

# Get stats and convert results to data frame 
SarahLavenderAllStatsRaw <- purrr::map_df(.x = sa_lav_ids, 
                                          .f = get_all_stats)

SarahLavenderAllStatsRaw %>% dplyr::glimpse(78)
