packages = c(
  'bs4Dash',
  'DT',
  'here',
  'leaflet',
  'leaflet.extras',
  'lubridate',
  'MASS',
  'RCurl',
  'rjson',
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
library(RCurl)
library(rjson)
library(shiny)
library(tidyverse)
library(plotly)
