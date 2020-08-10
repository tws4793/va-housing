library(ggplot2)
library(dplyr)
library(readr)
library(tidyr)
library(rjson)
library(jsonlite)
library(RCurl)


MRT <- read_csv("MRT list.csv")

latitude_list <- c()
longitude_list <- c()
X_list <- c()
Y_list <- c()
options(digits = 20)

for (i in c(1:119)) {
  addurl <- paste0("https://developers.onemap.sg/commonapi/search?searchVal=",
                   MRT$Address[i],
                   "&returnGeom=Y&getAddrDetails=N&pageNum=1")
  
  address_search <- URLencode(addurl)
  search_result <- fromJSON(address_search)
  
  if (as.numeric(search_result$found) > 0) {
    latitude <- as.numeric(search_result$results[1,]['LATITUDE'])
    longitude <- as.numeric(search_result$results[1,]['LONGITUDE'])
    X <- as.numeric(search_result$results[1,]['X'])
    Y <- as.numeric(search_result$results[1,]['Y'])
  } else {
    latitude <- 0
    longitude <- 0
    X <- 0
    Y <- 0
  }
  
  latitude_list <- append(latitude_list, latitude)
  longitude_list <- append(longitude_list, longitude)
  X_list <- append(X_list, X)
  Y_list <- append(Y_list, Y)
  
}

MRT_with_locations <- data.frame(MRT$MRT_station, MRT$Address, latitude_list, longitude_list, X_list, Y_list)
write_csv(MRT_with_locations, path = "MRT with Location.csv")
