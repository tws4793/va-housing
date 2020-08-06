packages = c(
    'bs4Dash',
    'tidyverse',
    'here',
    'rsconnect'
)

for(p in packages){
  if(!require(p, character.only = T)){
    install.packages(p)
  }
  library(p, character.only = T)
}
