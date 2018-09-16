train_path = 'train.csv'

train <- read.csv(train_path)

library(dplyr)

str(train)

train_tbl <- tbl_df(train)
# There is no primary key. Let's create one.
train_tbl$key <- seq.int(nrow(train_tbl))

# Create a clean version where we'll store our cleaned variables
clean_tbl <- train_tbl %>% select(key)
  
# Explore and clean the dataset column by column

# channelGrouping
table(train$channelGrouping)
temp <- train_tbl %>% 
  mutate(chan_affiliates = ifelse(channelGrouping == 'Affiliates', 1, 0),
         chan_direct = ifelse(channelGrouping == 'Direct', 1, 0),
         chan_display = ifelse(channelGrouping == 'Display', 1, 0),
         chan_organic = ifelse(channelGrouping == 'Organic Search', 1, 0),
         chan_paid = ifelse(channelGrouping == 'Paid Search', 1, 0),
         chan_referral = ifelse(channelGrouping == 'Referral', 1, 0),
         chan_social = ifelse(channelGrouping == 'Social', 1, 0),
         chan_other = ifelse(channelGrouping == '(Other)', 1, 0)) %>%
  select(key, chan_affiliates:chan_other)
clean_tbl <- clean_tbl %>% inner_join(temp)
rm(temp)

# date
temp <- train_tbl %>%
  mutate(year = as.integer(substr(as.character(date), 0, 4)),
         month = as.integer(substr(as.character(date), 5, 6)),
         day = as.integer(substr(as.character(date), 7, 8))
  ) %>%
  select(key, date, year, month, day)
clean_tbl <- clean_tbl %>% inner_join(temp)
rm(temp)

# device
library(jsonlite)

device_decoded = paste('[', paste(train$device, collapse = ','), ']') %>% fromJSON(flatten = T)
device_decoded$browser <- as.factor(device_decoded$browser)
device_decoded$operatingSystem <- as.factor(device_decoded$operatingSystem) 
device_decoded$isMobile <- as.integer(device_decoded$isMobile) # Originally TRUE/FALSE
device_decoded$deviceCategory <- as.factor(device_decoded$deviceCategory)
device_decoded <- tbl_df(device_decoded) %>%
  select(browser, operatingSystem, isMobile, deviceCategory)

device_decoded <- device_decoded %>%
  mutate(
    # Browsers
    b_chrome = ifelse(as.character(browser) == 'Chrome', 1, 0),
    b_safari = ifelse(as.character(browser) == 'Safari', 1, 0),
    b_firefox = ifelse(as.character(browser) == 'Firefox', 1, 0),
    b_ie = ifelse(as.character(browser) == 'Internet Explorer', 1, 0),
    b_edge = ifelse(as.character(browser) == 'Edge', 1, 0),
    b_android = ifelse(as.character(browser) == 'Android Webview', 1, 0),
    b_safari_app = ifelse(as.character(browser) == 'Safari (in-app)', 1, 0),
    b_opera_mini = ifelse(as.character(browser) == 'Opera Mini', 1, 0),
    b_uc = ifelse(as.character(browser) == 'UC Browser', 1, 0),
    b_other = ifelse(sum(b_chrome, b_safari, b_firefox, b_ie, b_edge, b_android, b_safari_app, b_opera_mini, b_uc) == 0, 1, 0),
    # Operating Systems
    os_windows = ifelse(as.character(operatingSystem) == 'Windows', 1, 0),  
    os_mac = ifelse(as.character(operatingSystem) == 'Macintosh', 1, 0),  
    os_android = ifelse(as.character(operatingSystem) == 'Android', 1, 0),  
    os_ios = ifelse(as.character(operatingSystem) == 'iOS', 1, 0),  
    os_linux = ifelse(as.character(operatingSystem) == 'Linux', 1, 0),  
    os_chrome = ifelse(as.character(operatingSystem) == 'Chrome OS', 1, 0),  
    os_not_set = ifelse(as.character(operatingSystem) == '(not set)', 1, 0),  
    os_windows_phone = ifelse(as.character(operatingSystem) == 'Windows Phone', 1, 0),  
    os_samsung = ifelse(as.character(operatingSystem) == 'Samsung', 1, 0),  
    os_blackberry = ifelse(as.character(operatingSystem) == 'BlackBerry', 1, 0),  
    os_other = ifelse(sum(os_windows, os_mac, os_android, os_ios, os_linux, os_chrome, os_not_set, os_windows_phone, os_samsung, os_blackberry) == 0, 1, 0),
    # Device Category
    dc_desktop = ifelse(as.character(deviceCategory) == 'desktop', 1, 0),
    dc_mobile = ifelse(as.character(deviceCategory) == 'mobile', 1, 0),
    dc_tablet = ifelse(as.character(deviceCategory) == 'tablet', 1, 0)
  ) %>%
  select(-c(browser, operatingSystem, deviceCategory))

clean_tbl <- clean_tbl %>% cbind(device_decoded)
rm(device_decoded)

# Visitor ID (category on which we will need to aggregate)
temp <- train_tbl %>%
  select(key, fullVisitorId) %>%
  mutate(fullVisitorId = as.character(fullVisitorId))
clean_tbl %>% inner_join(temp)
rm(temp)

# geoNetwork
geo_decoded = paste('[', paste(train$geoNetwork, collapse = ','), ']') %>% fromJSON(flatten = T)
geo_decoded <- tbl_df(geo_decoded)
# Create a new feature for top level domain
geo_decoded$parsed_domain <- gsub('^.*\\.','', geo_decoded$networkDomain)

# Retrieve lookup tables for encodings
continent_lookup <- read.csv('continent_lookup.csv', stringsAsFactors=FALSE)
sub_continent_lookup <- read.csv('sub_continent_lookup.csv', stringsAsFactors=FALSE)
country_lookup <- read.csv('country_lookup.csv', stringsAsFactors=FALSE)
region_lookup <- read.csv('region_lookup.csv', stringsAsFactors=FALSE)
metro_lookup <- read.csv('metro_lookup.csv', stringsAsFactors=FALSE)
city_lookup <- read.csv('city_lookup.csv',stringsAsFactors=FALSE)
domain_lookup <- read.csv('domain_lookup.csv', stringsAsFactors=FALSE)
parsed_domain_lookup <- read.csv('parsed_domain_lookup.csv', stringsAsFactors=FALSE)

geo_decoded <- geo_decoded %>% 
  left_join(continent_lookup) %>% 
  left_join(sub_continent_lookup) %>% 
  left_join(country_lookup) %>% 
  left_join(region_lookup) %>% 
  left_join(metro_lookup) %>% 
  left_join(city_lookup) %>% 
  left_join(domain_lookup) %>% 
  left_join(parsed_domain_lookup) %>%
  select(continent_id:parsed_domain_id)

clean_tbl <- clean_tbl %>% cbind(geo_decoded)
rm(geo_decoded)

# sessionId
temp <- train_tbl %>%
  group_by(sessionId) %>%
  summarize(total_sessions = n()) %>%
  arrange(desc(total_sessions))
temp2 <- train_tbl %>%
  select(key, sessionId) %>%
  inner_join(temp) %>%
  select(-sessionId)
clean_tbl <- clean_tbl %>% inner_join(temp2)
rm(temp, temp2)

train_tbl %>% group_by(as.character(fullVisitorId)) %>% summarize(count = n()) %>% arrange(desc(count))
