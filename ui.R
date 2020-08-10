# ui.R
# ======

### Components
# comp_map = 
settings_map = fluidRow(
  column(
    12,
    fluidRow(
      column(
        12,
        uiOutput('slide_year')
      )
    ),
    fluidRow(
      column(
        12,
        uiOutput('sel_flat_type')
      )
    ),
    fluidRow(
      column(
        12,
        uiOutput('ren_btn_reset_map')
      )
    )
  )
)

### PAGES

# Index
tb_index = menuItem(
  'Dashboard',
  tabName = 'index',
  icon = 'tachometer-alt'
)
pg_index = tabItem(
  tabName = 'index',
  fluidRow(
    box(
      fluidRow(
        column(
          6,
          h1('Year')
        ),
        column(
          6,
          uiOutput('slide_year_gdp')
        )
      ),
      closable = FALSE,
      collapsible = FALSE,
      width = 12
    )
  ),
  fluidRow(
    valueBoxOutput('vbox_hp', width = 3),
    valueBoxOutput('vbox_gdp_gr', width = 3),
    valueBoxOutput('vbox_gdp_pc', width = 3),
    valueBoxOutput('vbox_inf', width = 3)
  ),
  fluidRow(
    box(
      plotlyOutput('plt_gdp'),
      title = 'Singapore Economy vs Housing Price',
      collapsible = TRUE,
      closable = FALSE,
      maximizable = TRUE,
      width = 12,
      status = getAdminLTEColors()[8]
    )
  ),
  fluidRow(
    box(
      fluidRow(
        column(
          12,
          # tags$style(type = "text/css", "#map_sg {height: calc(100vh - 80px) !important;}"),
          uiOutput('map_sg_ui')
        )
      ),
      inputId = 'box_map',
      title = 'HDB Resale Price Distribution',
      enable_sidebar = TRUE,
      sidebar_content = settings_map,
      sidebar_icon = 'cog',
      collapsible = TRUE,
      closable = FALSE,
      maximizable = TRUE,
      width = 6,
      status = getAdminLTEColors()[8]
    ),
    box(
      fluidRow(
        column(
          12,
          dataTableOutput('dt_hdb_resale')
        )
      ),
      fluidRow(
        column(
          12,
          p()
        )
      ),
      title = 'HDB Resale Transactions',
      collapsible = TRUE,
      collapsed = FALSE,
      closable = FALSE,
      maximizable = TRUE,
      overflow = TRUE,
      width = 6,
      status = getAdminLTEColors()[8]
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

# Regression
tb_regression = menuItem(
  'Regression',
  tabName = 'regression',
  icon = 'chart-line'
)
pg_regression = tabItem(
  tabName = 'regression',
  fluidRow(
    box(
      fluidRow(
        column(
          12,
          'Settings'
        )
      ),
      hr(),
      fluidRow(
        column(
          12,
          span(
            strong('87.5'),
            style = 'font-size: 200px',
            align = 'center'
          )
        )
      ),
      title = 'Prediction',
      collapsible = FALSE,
      collapsed = FALSE,
      closable = FALSE,
      maximizable = TRUE,
      overflow = TRUE,
      width = 12,
      status = 'secondary'
    )
  )
)

# Help
tb_guide = menuItem(
  'User Guide',
  tabName = 'guide',
  icon = 'question'
)
pg_guide = tabItem(
  tabName = 'guide',
  fluidRow(
    column(
      12,
      includeMarkdown('notebook/guide.Rmd')
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
  sidebarMenu(
    tb_index,
    # tb_regression,
    tb_guide,
    tb_about
  ),
  skin = 'dark',
  status = getAdminLTEColors()[8],
  title = 'Housing Price',
  brandColor = getAdminLTEColors()[8],
  elevation = 13,
  opacity = 0.8
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
    pg_regression,
    pg_about,
    pg_guide
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
