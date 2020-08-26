library(dplyr)
library(here)
library(readr)
library(rjson)
library(jsonlite)
library(RCurl)

output_location = here('data/raw/hdb_resale_data.csv')

base_url = 'https://data.gov.sg/api/action/datastore_search'
resources = c(
  'adbbddd3-30e2-445f-a123-29bee150a6fe', # 1990 - 1999
  '8c00bf08-9124-479e-aeca-7cc411d884c4', # 2000 - 2012
  '83b2fc37-ce8c-4df4-968b-370fd818138b', # 2012 - 2014
  '1b702208-44bf-4829-b620-4615ee19b57c', # 2015 - 2016
  '42ff9cfe-abe5-4b54-beda-c88f9bb438ee' # 2017 - 2020
)

upper_limit = 370000

get_data_hdb = function(resource_id, upper_limit){
  url = paste0(base_url, '?resource_id=', resource_id, '&limit=', upper_limit)
  print(url)
  url_encoded = URLencode(url)
  
  raw = fromJSON(getURL(url_encoded))
  data = raw$result$records
  
  # Data from 2012 had an extra column, remaining lease, which we need to remove
  if(length(data) == 12){
    data = data[, -8]
  }
  
  df = rbind(df, data)
}

df = data.frame()
for(resource_id in resources){
  get_data_hdb(resource_id, upper_limit)
}

write.csv(df, output_location)
