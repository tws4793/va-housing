server = function(input, output){
  # GDP
  output$slide_year_gdp = renderUI({
    sliderInput(
      inputId = 'slide_year_gdp',
      label = NULL,
      width = '100%',
      min = as.numeric(min(sb_hdb_resale$year)),
      max = as.numeric(max(sb_hdb_resale$year)),
      value = c(2015, 2019)
    )
  })
  
  fmt_large = function(number, dp = 2){
    format(round(number, dp), nsmall = 1, big.mark = ',')
  }
  
  fmt_percent = function(number){
    paste0(round(number, 2), '%')
  }
  
  output$vbox_hp = renderbs4ValueBox({
    valueBox(
      value = paste0('S$ ', fmt_large(data_gdp[2,]$HDB_Resale_Price)),
      subtitle = 'Average HDB Resale Price',
      status = getAdminLTEColors()[8],
      icon = 'home'
    )
  })
  
  output$vbox_gdp_gr = renderbs4ValueBox({
    valueBox(
      value = fmt_percent(data_gdp[2,]$GDP_Growth),
      subtitle = 'GDP Growth',
      status = getAdminLTEColors()[8],
      icon = 'globe-asia',
      width = 3
    )
  })
  
  output$vbox_gdp_pc = renderbs4ValueBox({
    valueBox(
      value = paste0('S$ ', fmt_large(data_gdp[2,]$GDP_per_capita)),
      subtitle = 'GDP per Capita',
      status = getAdminLTEColors()[8],
      icon = 'user-friends',
      width = 3
    )
  })
  
  output$vbox_inf = renderbs4ValueBox({
    valueBox(
      value = fmt_percent(data_gdp[2,]$Inflation),
      subtitle = 'Inflation',
      status = getAdminLTEColors()[8],
      icon = 'chart-line',
      width = 3
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
      min = as.numeric(min(sb_hdb_resale$year)),
      max = as.numeric(max(sb_hdb_resale$year)),
      value = as.numeric(max(sb_hdb_resale$year))
    )
  })
  
  output$sel_flat_type = renderUI({
    choices = sb_hdb_resale %>%
      distinct(flat_type)
    append(choices, 'all')
    
    selectInput(
      inputId = 'sel_flat_type',
      label = 'HDB Type',
      choices = choices
    )
  })
  
  sb_hdb_resale_filter = reactive({
    sb_hdb_resale %>%
      filter(
        latitude_list_full != 0,
        year == input$slide_year,
        flat_type == input$sel_flat_type
      )
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
    
    # min = min(sb_hdb_resale$`Median Price`)
    # max = max(sb_hdb_resale$`Median Price`)
    # bins= 1:6 * 200000
    pal = colorBin(
      palette = "Reds",
      domain = c(
        min(sb_hdb_resale$`Median Price`),
        max(sb_hdb_resale$`Median Price`)
        # min, max
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
      setView(lng = settings$map$lng, lat = settings$map$lat, zoom = settings$map$zoom) %>%
      addCircleMarkers(
        data = sb_hdb_resale,
        lng = ~longitude_list_full,
        lat = ~latitude_list_full,
        radius = 1,
        color = ~pal(sb_hdb_resale$`Median Price`),
        opacity= 0.5,
        popup = popup
      ) %>%
      addMarkers( # Add MRT Stations
        data = data_mrt,
        lng = ~longitude_list,
        lat = ~latitude_list,
        icon = icon_mrt,
        label = data_mrt$`MRT.MRT_station`
      ) %>%
      addLegend(
        data = sb_hdb_resale,
        pal = pal,
        values = ~`Median Price`,
        position = 'bottomright',
        title = "Median Price (S$)"
      )
  })
  
  output$dt_hdb_resale = DT::renderDataTable(
    datatable(
      sb_hdb_resale_filter() %>%
        select(
          'Month' = month,
          'Town' = town,
          'Address' = full_address,
          'Storey Range' = storey_range,
          'Area (sqm)' = floor_area_sqm,
          'Resale Price' = resale_price,
        ),
      options = list(
        pageLength = 5,
        lengthMenu = c(5, 10, 25, 50, 100),
        order = list(
          list(0, 'asc')
        )
      ),
      rownames = FALSE
    )
  )
}