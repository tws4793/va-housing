# ui.R
# ======

### PAGES

# Index
tb_index = menuItem(
  'Home',
  tabName = 'index',
  icon = 'home'
)
pg_index = tabItem(
  tabName = 'index',
  fluidRow(
    h1('Housing Prices & GDP Overview')
  ),
  fluidRow(
    plotlyOutput('plt_gdp')
  )
)

# About
tb_about = menuItem(
  'About',
  tabName = 'about',
  icon = 'info'
)
pg_about = tabItem(
  tabName = 'about',
  includeMarkdown('notebook/about.Rmd')
)

# Map
tb_map = menuItem(
  'Map',
  tabName = 'map',
  icon = 'map'
)
pg_map = tabItem(
  tabName = 'map',
  fluidRow(
    h1('Map')
  ),
  fluidRow(
    leafletOutput('map_sg')
  ),
  fluidRow(
    
  )
)

### SETTINGS
user = sidebarUserPanel(
  img = 'https://vignette.wikia.nocookie.net/surrealmemes/images/0/09/Meme_Man_HD.png',
  text = textOutput('usr_name')
)

### MAIN

# Sidebar
sidebar = dashboardSidebar(
  skin = 'dark',
  status = getAdminLTEColors()[8],
  title = 'Housing Price',
  brandColor = getAdminLTEColors()[8],
  elevation = 3,
  opacity = 0.8,
  sidebarMenu(
    tb_index,
    tb_map,
    tb_about
  )
)

# Navbar
navbar = dashboardHeader(
  skin = 'light',
  status = getAdminLTEColors()[1],
  border = TRUE,
  sidebarIcon = 'bars',
  controlbarIcon = 'th',
  fixed = FALSE
)

# Control Bar
ctrl_bar = dashboardControlbar(
  skin = 'dark',
  title = 'Options',
  sliderInput(
    inputId = 'obs',
    label = 'Number of observations:',
    min = 0,
    max = 1000,
    value = 500
  ),
  column(
    width = 12,
    align = 'center',
    radioButtons(
      inputId = 'dist',
      label = 'Distribution type:',
      c('Normal' = 'norm',
        'Uniform' = 'unif',
        'Log-normal' = 'lnorm',
        'Exponential' = 'exp')
    )
  )
)

# Footer
footer = dashboardFooter(
  'ISSS 608 Visual Analytics & Applications',
  copyrights = NULL,
  right_text = '2020'
)

# Body
body = dashboardBody(
  tabItems(
    pg_index,
    pg_about,
    pg_map
  )
)

# UI
ui = dashboardPage(
  old_school = FALSE,
  sidebar_mini = TRUE,
  sidebar_collapsed = FALSE,
  controlbar_collapsed = TRUE,
  controlbar_overlay = TRUE,
  title = 'Housing Prices',
  navbar = navbar,
  sidebar = sidebar,
  controlbar = NULL,
  footer = NULL,
  body = body
)
