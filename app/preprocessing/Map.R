library('readr')
data = read_csv("data/HDB Resale data with Location.csv")
head(data)
# Get singapore map
library('tmaptools')
library('ggplot2')
library('ggmap')
singapore <-ggmap(get_stamenmap(rbind(as.numeric(paste(geocode_OSM("Singapore")$bbox))), zoom = 11))
#plot the points in the top 5 rows in the data
singapore + geom_point(data = head(data), aes(x = longitude_list, y = latitude_list), size = 3,colour = "red")
