packages = c(
    'bs4Dash',
    'ggplot2',
    'here',
    'leaflet',
    'lubridate',
    'rsconnect',
    # 'sf',
    'shiny',
    'tidyverse',
    'plotly'
)

for(p in packages){
  if(!require(p, character.only = T)){
    install.packages(p)
  }
  library(p, character.only = T)
}

settings = list(
  'map' = list(
    'lat' = 1.34,
    'lng' = 103.845,
    'zoom' = 11
  )
)

# Data

dir_data = list(
  'gdp' = here('data/output/gdp_sg.csv'),
  'hdb_resale' = here('data/output/hdb_resale.csv'),
  'mrt' = here('data/mrt_with_location.csv')
)
dir_icon_mrt = here('app/www/AWT-Train.png')

data_gdp = read_csv(dir_data$gdp)
data_hdb_resale = read_csv(dir_data$hdb_resale)
data_mrt = read_csv(dir_data$mrt)

icon_mrt = makeIcon(iconUrl = dir_icon_mrt, iconWidth = 6, iconHeight = 6)