  ## app.R ##
  
source('prep.R')
source('utils.R')



ui <- secure_app(
  dashboardPage(
    
    dashboardHeader(title = "Model Drift Monitoring"),
    
    dashboardSidebar(
      
      selectInput(
        inputId = "variable",
        label   = "Variables",
        choices = col_selects
      ),
      
      sliderInput(
        inputId = "dayinput",
        label   = "Last Days:",
        min     = 0,
        max     = 30,
        value   = 10
      )
    ),
    
    dashboardBody(
      
      fluidRow(
        
        valueBoxOutput("vbox"),
        valueBoxOutput("vbox2"),
        valueBoxOutput("vbox3"),
        
        box(
          title = 'PSI Comparison',
          highchartOutput("plot_psi"),
          height = 475
        ),
        
        box(
          title = textOutput('PSI'),
          formattableOutput("table"),
          height = 225
        )
      )
    )
  )
)
      
    
    
# server
server <- function(input, output, session) {
  

  # Reconnecting to MySQL DB after default millisecond
  observe({
    
    invalidateLater(2.80e+7, session)
    connect_db()
    
    })
  
  
  # Updating Data 
  df_test <- eventReactive(
    
    list(input$variable,input$dayinput), {
      get_dftest(n_day = input$dayinput)
      })
  
  
  # PSI Plot
  output$plot_psi <- renderHighchart({
    
    get_dist(
      df_train,
      df_test(),#'Gender'
      cols[input$variable]
      ) %>%
      draw_dist()
    
      })
  
  
  # PSI Value
  output$PSI <- renderText({
    
    PSI <- sum(
      get_table(
        df_train,
        df_test(),
        cols[input$variable]
      )$PSI
    )
    
    paste0('PSI: ', round(PSI,2))
    
    })
  
  
  # Last Day Input
  output$n_day <- renderText({
    
    input$dayinput
    
    })
  
  
  # PSI Table
  output$table <- renderFormattable({
    
    tb_tmp <-formattable(
      get_table(
        df_train,
        df_test(),
        var=cols[input$variable]
        ),
      align =c("l","c","c","c","c","c"),
      list(
        style = ~ style(
        color = "white",
        font.weight = "bold"
        ),
        `train`= color_tile('#CAF0F8', '#00B4D8'),
        `test` = color_tile('#CAF0F8', '#00B4D8'),
        diff   = sign_formatter
      )
    )
    
    tb_tmp
    
    })
    
  
  # Box Request  
  output$vbox <- renderValueBox({
    
    df <- get_boxdf1(df_test()) %>% 
      arrange(prediction_date) %>%
      count(prediction_date)
      
    req_n <- sum(df$n)
     
    hc <- hchart(df, "area", hcaes(prediction_date, n), name = "customer")  %>% 
      hc_size(height = 100) %>% 
      hc_credits(enabled = FALSE) %>% 
      hc_add_theme(hc_theme_sparkline_vb()) 
    
    valueBoxSpark(
      value = req_n,
      title = toupper("Total Number of Requests"),
      sparkobj = hc,
      subtitle = NULL,
      info = "This box shows customer requests taken by API endpoint for each day",
      width = 4,
      color = "teal",
      href = NULL
    )
    })
    
  
  # Box Probabilties  
  output$vbox2 <- renderValueBox({
    
    df <- get_boxdf1(df_test()) %>% 
      arrange(prediction_date) %>% 
      group_by(prediction_date) %>%
      summarise(proba=round(mean(prediction_proba),2))
    avg_prob <- paste0(round(mean(df$proba),1)*100,'%')
      
    hc2 <- hchart(df, "line", hcaes(prediction_date, proba), name = "Churn Probability")  %>% 
      hc_size(height = 100) %>% 
      hc_credits(enabled = FALSE) %>% 
      hc_add_theme(hc_theme_sparkline_vb()) 
    
    valueBoxSpark(
      value = avg_prob,
      title = toupper("Average Predicted Probability"),
      sparkobj = hc2,
      subtitle = NULL,
      info = "This box demonstrates average churn probability the model predicts for customers",
      width = 4,
      color = "red",
      href = NULL
    )
    
  })
    
    
  # Box Hourly Requests
  output$vbox3 <- renderValueBox({
    df <- get_boxdf1(df_test()) %>%
      mutate(pred_hour=hour(prediction_time)) %>%
      count(pred_hour)
      
      
  
    hc3 <- hchart(df, "column", hcaes(pred_hour, n), name = "Hourly Requests")  %>%
      hc_size(height = 100) %>%
      hc_credits(enabled = FALSE) %>%
      hc_add_theme(hc_theme_sparkline_vb())

    valueBoxSpark(
      value    = "25",
      title    = toupper("Average Hourly Requests"),
      sparkobj = hc3,
      subtitle = NULL,
      info     = "This box demonstrates hourly request number by the customers for the whole month",
      width    = 4,
      color    = "yellow",
      href     = NULL
    )

  })
    
  
  # Authonticator Server Side  
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )
  

}                
  
  
  
  # RunApp
  shinyApp(ui, server)
