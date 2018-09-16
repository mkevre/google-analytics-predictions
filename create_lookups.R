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

