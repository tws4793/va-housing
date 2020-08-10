# ui.R
# ======

### Components
# comp_map = 

### PAGES

# Index
tb_index = menuItem(
  'Dashboard',
  tabName = 'index',
  icon = 'tachometer-alt'
)
pg_index = tabItem(
  tabName = 'index',
  # fluidRow(
  #   box(
  #     fluidRow(
  #       column(
  #         8,
  #         'Select a range of years'
  #       ),
  #       column(
  #         4,
  #         uiOutput('slide_year_gdp')
  #       )
  #     ),
  #     title = 'Options',
  #     collapsible = TRUE,
  #     closable = FALSE,
  #     maximizable = TRUE,
  #     width = 12
  #   )
  # ),
  fluidRow(
    valueBoxOutput('vbox_hp'),
    valueBoxOutput('vbox_gdp_gr'),
    valueBoxOutput('vbox_gdp_pc'),
    valueBoxOutput('vbox_inf')
  ),
  fluidRow(
    box(
      plotlyOutput('plt_gdp'),
      title = 'Singapore Economy vs Housing Price',
      collapsible = TRUE,
      closable = FALSE,
      maximizable = TRUE,
      width = 6,
      status = 'secondary'
    ),
    box(
      fluidRow(
        column(
          12,
          leafletOutput('map_sg')
        )
      ),
      title = 'Property Price Distribution',
      enable_sidebar = TRUE,
      sidebar_content = fluidRow(
        column(
          12,
          uiOutput('slide_year'),
          uiOutput('sel_flat_type')
        )
      ),
      collapsible = TRUE,
      closable = FALSE,
      maximizable = TRUE,
      width = 6,
      status = 'secondary'
    )
  ),
  fluidRow(
    box(
      fluidRow(
        column(
          12,
          dataTableOutput('dt_hdb_resale')
        )
      ),
      title = 'Historical Transactions',
      collapsible = TRUE,
      collapsed = TRUE,
      closable = FALSE,
      maximizable = TRUE,
      overflow = TRUE,
      width = 12,
      status = 'secondary'
    )
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
  fluidRow(
    column(
      12,
      includeMarkdown('notebook/about.Rmd')
    )
  )
)

# Map
# tb_map = menuItem(
#   'Housing Prices',
#   tabName = 'map',
#   icon = 'map'
# )
# pg_map = tabItem(
#   tabName = 'map',
#   fluidRow(
#     box(
#       fluidRow(
#         column(
#           10,
#           leafletOutput('map_sg')
#         ),
#         column(
#           2,
#           uiOutput('slide_year'),
#           uiOutput('sel_flat_type')
#         )
#       ),
#       fluidRow(
#         column(
#           12,
#           tags$p()
#         ),
#         column(
#           12,
#           dataTableOutput('dt_hdb_resale')
#         )
#       ),
#       collapsible = FALSE,
#       closable = FALSE,
#       maximizable = TRUE,
#       width = 12,
#       height = '100%'
#     )
#   )
# )

# Regression
tb_regression = menuItem(
  'Regression',
  tabName = 'regression',
  icon = 'chart-line'
)
pg_regression = tabItem(
  tabName = 'regression',
  fluidRow(
    h1('Prediction')
  )
)

# Help
tb_help = menuItem(
  'Help',
  tabName = 'help',
  icon = 'question'
)
pg_help = tabItem(
  tabName = 'help',
  fluidRow(
    column(
      12,
      includeMarkdown('notebook/help.Rmd')
    )
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
    # tb_map,
    tb_regression,
    tb_help,
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
  # fluidRow(
  #   column(
  #     12,
  #     uiOutput('slide_year'),
  #     uiOutput('sel_flat_type')
  #   )
  # )
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
    # pg_map,
    pg_regression,
    pg_about,
    pg_help
  )
)

# UI
ui = dashboardPage(
  old_school = FALSE,
  sidebar_mini = TRUE,
  sidebar_collapsed = TRUE,
  controlbar_collapsed = TRUE,
  controlbar_overlay = TRUE,
  title = 'Housing Prices',
  navbar = navbar,
  sidebar = sidebar,
  controlbar = NULL,
  footer = NULL,
  body = body
)
