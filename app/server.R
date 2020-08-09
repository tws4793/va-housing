server = function(input, output){
  
  # Setting
  output$setting_status = renderText({
    paste()
  })
  
  # User
  output$usr_img = renderText({
    paste('https://vignette.wikia.nocookie.net/surrealmemes/images/0/09/Meme_Man_HD.png')}
  )
  output$usr_name = renderText({
    paste('Meme Man')}
  )
  
  # GDP
  output$vbox_gdp_pc = renderbs4ValueBox({
    valueBox(
      value = 25,
      subtitle = 'GDP per Capita',
      status = 'success',
      icon = 'user-friends'
    )
  })
  
  output$vbox_gdp = renderbs4ValueBox({
    valueBox(
      value = 50,
      subtitle = 'GDP',
      status = 'success',
      icon = 'globe-asia'
    )
  })
  
  output$vbox_hp = renderbs4ValueBox({
    valueBox(
      value = 50, # Mean of housing prices over a selected period (e.g. 2015 - 2019)
      subtitle = 'Housing Prices',
      status = 'success',
      icon = 'home'
    )
  })
  
  output$plt_gdp = renderPlotly({
    title = 'Singapore Economy & Housing Price'
    
    axis_y1 = list(
      tickfont = list(color = 'blue'),
      title = 'GDP per Capita'
    )
    
    axis_y2 = list(
      tickfont = list(color = "orange"),
      overlaying = "y",
      side = "right",
      title = "Housing_Price"
    )
    
    plot_ly() %>%
      add_lines(x = ~data_gdp$Year, y = ~data_gdp$GDP_per_capita, name = 'GDP per Capita') %>%
      add_lines(x = ~data_gdp$Year, y = ~data_gdp$HDB_Resale_Price, name = 'HDB Resale Price', yaxis = 'y2') %>%
      layout(
        title = title,
        yaxis = axis_y1,
        yaxis2 = axis_y2,
        xaxis = list(title = 'Year')
      )
  })
  
  # Map
  output$slide_year = renderUI({
    sliderInput(
      inputId = 'slide_year',
      label = 'Year',
      min = 2013,
      max = 2019,
      value = 2019
    )
  })
  
  output$sel_flat_type = renderUI({
    selectInput(
      inputId = 'sel_flat_type',
      label = 'HDB Type',
      choices = data_hdb_resale %>%
        distinct(flat_type)
    )
  })
  
  output$dt_hdb_resale = DT::renderDataTable({
    data_hdb_resale %>%
      select(
        full_address,
        town,
        flat_type,
        flat_model,
        floor_area_sqm,
        resale_price,
        month,
        storey_range
      )
  })
  
  map_hdb_prices = reactive({
    data_hdb_resale %>%
      mutate(
        year = substr(month, start = 1, stop = 4),
        full_address=str_to_title(full_address)
      ) %>%
      filter(
        latitude_list_full != 0,
        year == input$slide_year,
        flat_type == input$sel_flat_type
        # year == '2019'
        # flat_type == '4 ROOM'
      ) %>%
      group_by(
        full_address,
        latitude_list_full,
        longitude_list_full,
        closest_MRT,closest_distance,
        CBD_dist
      ) %>%
      summarize(
        'Median Price' = median(resale_price),
        'Volume' = n(),
        'Median Area' = median(floor_area_sqm),
        'Median Lease Start Date' = median(lease_commence_date)
      )
  })
  
  output$map_sg = renderLeaflet({
    dist_hdb_flat_type = data_hdb_resale %>%
      dplyr::distinct(flat_type)
    
    dist_hdb_year = data
    
    sb_hdb_resale = map_hdb_prices()
    
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
    #TODO: radius = data_detached$`Area (sqf)`/1000,
  })
    
}
