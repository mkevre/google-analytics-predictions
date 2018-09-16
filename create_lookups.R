# The following code is only to establish integer encodings based on training data
continents <- data.frame(continent = levels(as.factor(geo_decoded$continent)))
continents$continent_id <- seq.int(nrow(continents))
write.csv(continents, 'continent_lookup.csv', row.names = FALSE)

sub_continents <- data.frame(subContinent = levels(as.factor(geo_decoded$subContinent)))
sub_continents$sub_continent_id <- seq.int(nrow(sub_continents))
write.csv(sub_continents, 'sub_continent_lookup.csv', row.names = FALSE)

countries <- data.frame(country = levels(as.factor(geo_decoded$country)))
countries$country_id <- seq.int(nrow(countries))
write.csv(countries, 'country_lookup.csv', row.names = FALSE)

regions <- data.frame(region = levels(as.factor(geo_decoded$region)))
regions$region_id <- seq.int(nrow(regions))
write.csv(regions, 'region_lookup.csv', row.names = FALSE)

metros <- data.frame(metro = levels(as.factor(geo_decoded$metro)))
metros$metro_id <- seq.int(nrow(metros))
write.csv(metros, 'metro_lookup.csv', row.names = FALSE)

cities <- data.frame(city = levels(as.factor(geo_decoded$city)))
cities$city_id <- seq.int(nrow(cities))
write.csv(cities, 'city_lookup.csv', row.names = FALSE)

domains <- data.frame(networkDomain = levels(as.factor(geo_decoded$networkDomain)))
domains$domain_id <- seq.int(nrow(domains))
write.csv(domains, 'domain_lookup.csv', row.names = FALSE)

# Create a new feature for top level domain
geo_decoded$parsed_domain <- gsub('^.*\\.','', geo_decoded$networkDomain)
parsed_domains <- data.frame(parsed_domain = levels(as.factor(geo_decoded$parsed_domain)))
parsed_domains$parsed_domain_id <- seq.int(nrow(parsed_domains))
write.csv(parsed_domains, 'parsed_domain_lookup.csv', row.names = FALSE)


# Traffic sources

campaigns <- data.frame(campaign = levels(as.factor(traffic_decoded$campaign)))
campaigns$campaign_id <- seq.int(nrow(campaigns))
write.csv(campaigns, 'campaign_lookup.csv', row.names = FALSE)

sources <- data.frame(source = levels(as.factor(traffic_decoded$source)))
sources$source_id <- seq.int(nrow(sources))
write.csv(sources, 'source_lookup.csv', row.names = FALSE)

mediums <- data.frame(medium = levels(as.factor(traffic_decoded$medium)))
mediums$medium_id <- seq.int(nrow(mediums))
write.csv(mediums, 'medium_lookup.csv', row.names = FALSE)

keywords <- data.frame(keyword = levels(as.factor(traffic_decoded$keyword)))
keywords$keyword_id <- seq.int(nrow(keywords))
write.csv(keywords, 'keyword_lookup.csv', row.names = FALSE)

referral_paths <- data.frame(referralPath = levels(as.factor(traffic_decoded$referralPath)))
referral_paths$ref_path_id <- seq.int(nrow(referral_paths))
write.csv(referral_paths, 'referral_path_lookup.csv', row.names = FALSE)

ad_contents <- data.frame(adContent = levels(as.factor(traffic_decoded$adContent)))
ad_contents$ad_content_id <- seq.int(nrow(ad_contents))
write.csv(ad_contents, 'ad_content_lookup.csv', row.names = FALSE)

# Campaign code is useless

ad_net_types <- data.frame(adwordsClickInfo.adNetworkType = levels(as.factor(traffic_decoded$adwordsClickInfo.adNetworkType)))
ad_net_types$ad_net_type_id <- seq.int(nrow(ad_net_types))
write.csv(ad_net_types, 'ad_net_type_lookup.csv', row.names = FALSE)

gcl_ids <- data.frame(adwordsClickInfo.gclId = levels(as.factor(traffic_decoded$adwordsClickInfo.gclId)))
gcl_ids$gclId_id <- seq.int(nrow(gcl_ids))
write.csv(gcl_ids, 'gcl_id_lookup.csv', row.names = FALSE)
