### Settings
settings = list(
  'map' = list(
    'lat' = 1.34,
    'lng' = 103.845,
    'zoom' = 11
  )
)

packages = c(
    'bs4Dash',
    'DT',
    'here',
    'leaflet',
    'lubridate',
    'shiny',
    'tidyverse',
    'plotly'
)

### Deployment
for(p in packages){
  if(!require(p, character.only = T)){
    install.packages(p)
  }
  library(p, character.only = T)
}

# Overcome limitation of shinyapps
library(bs4Dash)
library(here)
library(leaflet)
library(lubridate)
library(shiny)
library(tidyverse)
library(plotly)

### Data
dir_data = list(
  'gdp' = here('data/output/gdp_sg.csv'),
  'hdb_resale' = here('data/output/hdb_resale.csv'),
  'mrt' = here('data/output/mrt_with_location.csv')
)
dir_icon_mrt = here('www/AWT-Train.png')

data_gdp = read_csv(dir_data$gdp)
data_hdb_resale = read_csv(dir_data$hdb_resale)
data_mrt = read_csv(dir_data$mrt)

icon_mrt = makeIcon(iconUrl = dir_icon_mrt, iconWidth = 6, iconHeight = 6)

### Data Wrangling
sb_hdb_resale = data_hdb_resale %>%
  mutate(
    year = substr(month, start = 1, stop = 4),
    full_address = str_to_title(full_address)
  )