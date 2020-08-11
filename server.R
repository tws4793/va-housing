server = function(input, output){
  # GDP
  output$slide_year_gdp = renderUI({
    sliderInput(
      inputId = 'slide_year_gdp',
      label = NULL,
      width = '100%',
      ticks = FALSE,
      min = as.numeric(min(data_gdp$Year)),
      max = as.numeric(max(data_gdp$Year)),
      value = 2019
    )
  })
  
  sb_key_figures = reactive({
    data_gdp %>%
      filter(Year == input$slide_year_gdp)
  })
  
  fmt_large = function(number, dp = 2){
    format(round(number, dp), nsmall = 2, big.mark = ',')
  }
  
  fmt_percent = function(number){
    paste0(round(number, 2), '%')
  }
  
  fmt_valuebox = function(figure, subtitle, icon, status = getAdminLTEColors()[8], width = 3){
    valueBox(
      value = span(figure, style = 'font-size: 2.2rem'),
      subtitle = paste0(subtitle, ' (', input$slide_year_gdp, ')'),
      status = status,
      icon = icon,
      width = width
    )
  }
  
  output$vbox_hp = renderbs4ValueBox({
    fmt_valuebox(
      paste0('S$ ', fmt_large(sb_key_figures()$HDB_Resale_Price)),
      'Average HDB Resale Price',
      'home'
    )
  })
  
  output$vbox_gdp_gr = renderbs4ValueBox({
    fmt_valuebox(
      fmt_percent(sb_key_figures()$GDP_Growth),
      'GDP Growth',
      'globe-asia'
    )
  })
  
  output$vbox_gdp_pc = renderbs4ValueBox({
    fmt_valuebox(
      paste0('US$ ', fmt_large(sb_key_figures()$GDP_per_capita)),
      'GDP per Capita',
      'user-friends'
    )
  })
  
  output$vbox_inf = renderbs4ValueBox({
    fmt_valuebox(
      fmt_percent(sb_key_figures()$Inflation),
      'Overall Inflation',
      'chart-line'
    )
  })
  
  output$plt_gdp = renderPlotly({
    title = 'Singapore Economy & Housing Price'
    
    y1_max = max(data_gdp$GDP_per_capita)
    y2_max = max(data_gdp$HDB_Resale_Price)
    y1_const = 3811.221
    y2_const = 23559
    y_tick_bins = 5
    
    axis_y1 = list(
      title = 'GDP per Capita',
      tickfont = list(color = 'blue'),
      tick0 = 0,
      range = c(0, y1_max + y1_const),
      dtick = (y1_max + y1_const) / y_tick_bins,
      autotick = FALSE,
      color = 'blue'
    )
    
    axis_y2 = list(
      title = 'Housing Price',
      tickfont = list(color = 'red'),
      overlaying = 'y',
      side = 'right',
      tick0 = 0,
      range = c(0, y2_max + y2_const),
      dtick = (y2_max + y2_const) / y_tick_bins,
      autotick = FALSE,
      color = 'red',
      gridcolor = 'lightgrey'
    )
    
    plot_ly() %>%
      add_trace(
        x = ~data_gdp$Year,
        y = ~data_gdp$GDP_per_capita,
        name = 'GDP per Capita',
        mode = 'lines+markers'
      ) %>%
      add_trace(
        x = ~data_gdp$Year,
        y = ~data_gdp$HDB_Resale_Price,
        name = 'HDB Resale Price',
        mode = 'lines+markers',
        yaxis = 'y2',
        line = list(color = "red", width = 2),
        marker = list(color = "red", width = 2)
      ) %>%
      layout(
        # title = title,
        yaxis = axis_y1,
        yaxis2 = axis_y2,
        xaxis = list(
          title = 'Year',
          color = 'black',
          linecolor = 'lightgrey',
          showgrid = FALSE,
          ticks = 'outside',
          tickcolor = 'lightgrey'
        ),
        hovermode = 'x unified'
        # legend = list(x = 0.1, y = 0.1)
      )
  })
  
  # Map
  output$slide_year = renderUI({
    sliderInput(
      inputId = 'slide_year',
      label = 'Year',
      ticks = FALSE,
      min = as.numeric(min(sb_hdb_resale$year)),
      max = as.numeric(max(sb_hdb_resale$year)),
      value = as.numeric(max(sb_hdb_resale$year))
    )
  })
  
  output$sel_flat_type = renderUI({
    choices = c('ALL', hdb_flat_types_order)
    
    selectInput(
      inputId = 'sel_flat_type',
      label = 'HDB Type',
      choices = choices
    )
  })
  
  output$ren_btn_reset_map = renderUI({
    actionButton('btn_reset_map', 'Reset Map', width = '100%')
  })
  
  observe({
    input$btn_reset_map
    leafletProxy('map_sg') %>%
      setView(
        lng = settings$map$lng,
        lat = settings$map$lat,
        zoom = settings$map$zoom
      )
  })
  
  sb_hdb_resale_filter = reactive({
    # https://stackoverflow.com/questions/38108515/r-shiny-display-full-dataframe-without-filter-input-until-filterinputs-are-chang
    input_flat_type = 
      if(input$sel_flat_type == 'ALL') hdb_flat_types_order
      else input$sel_flat_type
    
    sb_hdb_resale %>%
      filter(
        latitude_list_full != 0,
        year == input$slide_year,
        flat_type %in% input_flat_type
      ) %>%
      arrange(
        year_month
      )
  })
  
  output$map_sg_ui = renderUI({
    leafletOutput('map_sg')
  })
  
  output$map_sg = renderLeaflet({
    sb_hdb_resale = sb_hdb_resale_filter() %>%
      group_by(
        full_address,
        latitude_list_full,
        longitude_list_full,
        closest_MRT,
        closest_distance,
        CBD_dist
      ) %>%
      summarize(
        'Median Price' = median(resale_price),
        'Volume' = n(),
        'Median Area' = median(floor_area_sqm),
        'Median Lease Start Date' = median(lease_commence_date)
      )
    
    popup = paste(
      "Address: ", sb_hdb_resale$full_address, "<br />",
      "Median Area (sqm): ", sb_hdb_resale$`Median Area`, "<br />",
      "Median Price (S$): ", format(round(sb_hdb_resale$`Median Price`,digits=2),nsmall=2,big.mark=","), "<br />",
      "Median Lease Start Date: ", sb_hdb_resale$`Median Lease Start Date`, "<br />",
      "Closest MRT: ", sb_hdb_resale$closest_MRT, "<br />",
      "Distance from MRT (m): ", format(round(sb_hdb_resale$closest_distance,digits=2),nsmall=2,big.mark=","), "<br />",
      "Distance from CBD (m): ", format(round(sb_hdb_resale$CBD_dist,digits=2),nsmall=2,big.mark=",")
    )
    
    pal = colorBin(
      palette = 'Reds',
      domain = c(
        min(sb_hdb_resale$`Median Price`),
        max(sb_hdb_resale$`Median Price`)
      ),
      bins = 1:6 * 200000
    )
    
    map_layers = c("CartoDB.Positron", "OpenStreetMap", "Esri.WorldTopoMap")
    
    leaflet() %>%
      addTiles(group = map_layers[2]) %>%
      addProviderTiles(map_layers[1], group = map_layers[1]) %>%
      addProviderTiles(map_layers[3], group = map_layers[3]) %>%
      addLayersControl(
        baseGroups = map_layers,
        options = layersControlOptions(collapsed = TRUE)
      ) %>%
      setView(
        lng = settings$map$lng,
        lat = settings$map$lat,
        zoom = settings$map$zoom
      ) %>%
      addCircleMarkers(
        data = sb_hdb_resale,
        lng = ~longitude_list_full,
        lat = ~latitude_list_full,
        radius = 1,
        color = ~pal(sb_hdb_resale$`Median Price`),
        opacity= 0.5,
        popup = popup,
        group = 'circles'
      ) %>%
      addMarkers( # Add MRT Stations
        data = data_mrt,
        lng = ~longitude_list,
        lat = ~latitude_list,
        icon = icon_mrt,
        label = data_mrt$`MRT.MRT_station`,
        group = 'markers'
      ) %>%
      addLegend(
        data = sb_hdb_resale,
        pal = pal,
        values = ~`Median Price`,
        position = 'bottomright',
        title = 'Median Price (S$)'
      ) %>%
      addSearchFeatures(
        targetGroups = 'markers', # group should match addMarkers() group
        options = searchFeaturesOptions(
          zoom = 14,
          openPopup = TRUE,
          firstTipSubmit = TRUE,
          autoCollapse = TRUE,
          hideMarkerOnCollapse = TRUE
      )
      )
  })
  
  # DataTable
  output$dt_hdb_resale = DT::renderDataTable(
    datatable(
      sb_hdb_resale_filter() %>%
        select(
          'Month' = year_month_fmt,
          'Town' = town,
          'Address' = full_address,
          'Storey Range' = storey_range,
          'Area (sqm)' = floor_area_sqm,
          'Resale Price (S$)' = resale_price,
        ),
      options = list(
        pageLength = 5,
        lengthMenu = c(5, 10, 25, 50, 100)
      ),
      rownames = FALSE
    )
  )
  
  # Regression
  output$dd_regr_flat_type = renderUI({
    selectInput(
      inputId = 'in_regr_flat_type',
      label = 'Flat Type',
      choices = hdb_flat_types_order,
      width = '100%'
    )
  })
  
  output$dd_regr_storey_range = renderUI({
    choices = sb_hdb_resale %>%
      distinct(storey_range) %>%
      arrange(storey_range)
    
    selectInput(
      inputId = 'in_regr_storey_range',
      label = 'Storey Range',
      choices = choices,
      width = '100%'
    )
  })
  
  output$nb_regr_floor_area = renderUI({
    min = min(sb_hdb_resale$floor_area_sqm)
    max = max(sb_hdb_resale$floor_area_sqm)
    med = median(sb_hdb_resale$floor_area_sqm)
    
    numericInput(
      inputId = 'in_regr_floor_area',
      label = 'Floor Area (sqm)',
      value = med,
      min = min,
      max = max,
      width = '100%'
    )
  })
  
  output$nb_regr_dist_cbd = renderUI({
    numericInput(
      inputId = 'in_regr_dist_cbd',
      label = 'Distance to CBD (m)',
      value = 0,
      width = '100%'
    )
  })
  
  regr_estimate_value = reactive({
    fit$coefficients[1] +
      # Flat Type
      fit$coefficients[2] * (input$in_regr_flat_type == '2 ROOM') +
      fit$coefficients[3] * (input$in_regr_flat_type == '3 ROOM') +
      fit$coefficients[4] * (input$in_regr_flat_type == '4 ROOM') +
      fit$coefficients[5] * (input$in_regr_flat_type == '5 ROOM') +
      fit$coefficients[6] * (input$in_regr_flat_type == 'EXECUTIVE') +
      fit$coefficients[7] * (input$in_regr_flat_type == 'MULTI-GENERATION') +
      # Floor Area
      fit$coefficients[8] * input$in_regr_floor_area +
      # Storey Range
      fit$coefficients[9] * (input$in_regr_storey_range == '01 TO 05') +
      fit$coefficients[10] * (input$in_regr_storey_range == '04 TO 06') +
      fit$coefficients[11] * (input$in_regr_storey_range == '06 TO 10') +
      fit$coefficients[12] * (input$in_regr_storey_range == '07 TO 09') +
      fit$coefficients[13] * (input$in_regr_storey_range == '10 TO 12') +
      fit$coefficients[14] * (input$in_regr_storey_range == '11 TO 15') +
      fit$coefficients[15] * (input$in_regr_storey_range == '13 TO 15') +
      fit$coefficients[16] * (input$in_regr_storey_range == '16 TO 18') +
      fit$coefficients[17] * (input$in_regr_storey_range == '16 TO 20') +
      fit$coefficients[18] * (input$in_regr_storey_range == '19 TO 21') +
      fit$coefficients[19] * (input$in_regr_storey_range == '21 TO 25') +
      fit$coefficients[20] * (input$in_regr_storey_range == '22 TO 24') +
      fit$coefficients[21] * (input$in_regr_storey_range == '25 TO 27') +
      fit$coefficients[22] * (input$in_regr_storey_range == '26 TO 30') +
      fit$coefficients[23] * (input$in_regr_storey_range == '28 TO 30') +
      fit$coefficients[24] * (input$in_regr_storey_range == '31 TO 33') +
      fit$coefficients[25] * (input$in_regr_storey_range == '31 TO 35') +
      fit$coefficients[26] * (input$in_regr_storey_range == '34 TO 36') +
      fit$coefficients[27] * (input$in_regr_storey_range == '36 TO 40') +
      fit$coefficients[28] * (input$in_regr_storey_range == '37 TO 39') +
      fit$coefficients[29] * (input$in_regr_storey_range == '40 TO 42') +
      fit$coefficients[30] * (input$in_regr_storey_range == '43 TO 45') +
      fit$coefficients[31] * (input$in_regr_storey_range == '46 TO 48') +
      fit$coefficients[32] * (input$in_regr_storey_range == '49 TO 51') +
      # Distance to CBD
      fit$coefficients[33] * input$in_regr_dist_cbd
  })
  
  output$txt_regr_final = renderUI({
    text = paste0('S$', fmt_large(regr_estimate_value()))
    
    p(
      strong(text),
      style = 'font-size: 4rem',
      align = 'center',
    )
  })
}
