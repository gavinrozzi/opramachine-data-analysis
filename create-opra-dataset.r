library(tidyverse)
library(sqldf)

# To get latest OPRA data: run ruby export code for authorities from Rails console
# and copy from Postgres for requests and users.

# Read in data from CSV data exports
authorities <- read_csv("authority-export.csv")
requests <- read_csv("info_requests-12-11-19.csv")
users <- read_csv("om_users_confirmed_12-11-19.csv")

# Rename columns to prevent duplicate names
users <- users %>% rename(user_name = name)
requests <- requests %>% rename(request_updated_at = updated_at)
requests <- requests %>% rename(request_created_at = created_at)
authorities <- authorities %>% rename(public_body_name = name)

# Remove problematic columns from users
# R doesn't like them and they're not important anyway
users <- subset(users, select = -c(created_at, updated_at))

# Combine into one dataframe
join_requests <- "SELECT * FROM requests INNER JOIN authorities ON authorities.id = requests.public_body_id"
joined_data <- sqldf(join_requests, stringsAsFactors = FALSE)
join_users <- "SELECT * FROM joined_data INNER JOIN users ON users.id = joined_data.user_id"
joined_data <- sqldf(join_users, stringsAsFactors = FALSE)

# Select just the data that is relevant for this analysis
condense <- "SELECT id AS request_id, title, url_title, public_body_name AS requested_from, user_name AS requested_by, described_state, 
awaiting_description, request_created_at, request_updated_at, date_initial_request_last_sent_at, date_response_required_by, date_very_overdue_after, last_public_response_at, tag_string 
FROM joined_data ORDER BY request_created_at ASC"

# Create the final dataframe of requests w/ users and authorities
combined_opra_data <- sqldf(condense, stringsAsFactors = FALSE)

# Write out the final file
write.csv(combined_opra_data,"opra_data.csv", row.names = TRUE)