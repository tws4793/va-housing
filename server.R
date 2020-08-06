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
}
