## Intro
rm(list = ls())

case_records <- read.csv("data-raw\\case_records.csv")


case_records$date_admission <- as.Date(case_records$date_admission, format = "%d-%m-%Y")
case_records$dischage_date <- as.Date(case_records$dischage_date, format = "%d-%m-%Y")
case_records$death_date <- as.Date(case_records$death_date, format = "%d-%m-%Y")
case_records$event <- as.Date(case_records$event, format = "%d-%m-%Y")



# Fill in missing time-series ---------------------------------------------
# From: http://goo.gl/YpSvSz

# Split by location
loc <- split(case_records, f = case_records$location)

start <- as.Date(0, origin = "1970-01-01") # initialized as date format
end <- as.Date(0, origin = "1970-01-01")
full <- list(as.Date(0, origin = "1970-01-01"))
cases <- list()
cases_full <- list()
for (i in 1:length(loc)){
  start[i] <- as.Date(min(loc[[i]]$date_admission))
  end[i] <- max(loc[[i]]$date_admission)
  full[[i]] <- seq(start[i], by = '1 day', length = (end[i] - start[i]))

  cases[[i]] <- data.frame(table(loc[[i]]$date_admission))
  cases[[i]]$Var1 <- as.Date(cases[[i]]$Var1)
  ### ADD DEATH COUNT HERE
  colnames(cases[[i]]) <- c("date", "value")

  # Use matching to merge based on if there is an exisiting value or not
  cases_full[[i]] <- data.frame(date = full[[i]],
                           value = with(cases[[i]],
                                        value[match(full[[i]], date)]))
cases_full[[i]]$value[is.na(cases_full[[i]]$value) ] <- 0
}
# Name the locations since this data was lost above
cases_full[[1]]$location <- "frederikshavn"
cases_full[[2]]$location <-'nykoebing'

# Re-combine into df
cases_full <- do.call(rbind.data.frame, cases_full)
cholera_daily_data_towns <- cases_full

# SAVING ------------------------------------------------------------------
devtools::use_data(case_records, overwrite = T)
devtools::use_data(cholera_daily_data_towns, overwrite = T)