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
    'leaflet.extras',
    'lubridate',
    'MASS',
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
library(leaflet.extras)
library(lubridate)
library(MASS)
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
hdb_flat_types_order = c(
  '1 ROOM',
  '2 ROOM',
  '3 ROOM',
  '4 ROOM',
  '5 ROOM',
  'EXECUTIVE',
  'MULTI-GENERATION'
)

sb_hdb_resale = data_hdb_resale %>%
  rename(
    year_month = month
  ) %>%
  mutate(
    year_month_fmt = format(parse_date_time(year_month, orders = c('Y-m')), '%b %Y'),
    month = substr(year_month, start = 6, stop = 7),
    year = substr(year_month, start = 1, stop = 4),
    flat_type = fct_relevel(flat_type, hdb_flat_types_order)
  )

fit = lm(
  resale_price ~ flat_type + floor_area_sqm + storey_range + CBD_dist,
  data = sb_hdb_resale
)
# names(fit$coefficients)
# step = stepAIC(fit, direction = "both")
