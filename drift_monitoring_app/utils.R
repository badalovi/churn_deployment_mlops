get_dftest <- function(db=mydb,n_day){
  
  df_test_init <- fetch(dbSendQuery(mydb, 'select * from churn'),n = -1)
  
  # Preparing Data
  
  df_test <-
    df_test_init %>%
    mutate(
      creditscore_bin = cut(creditscore,c(0,600,700,850),
                            labels=c('<350','350-600','600-850')),
      
      age_bin = cut(age,c(17,35,45,100),labels=c('18-35','35-45','45+')),
      
      tenure_bin = cut(tenure,c(0,3,5,7,10),labels=c('<3','3-5','5-7','+7'),right=FALSE),
      
      balance_bin = cut(balance,c(0,100000,130000,170000,300000),
                        labels = c('<100K','100K-130K','130K-170K','+170K'),right=FALSE),
      
      estimatedsalary_bin = cut(estimatedsalary,c(10,50000,100000,150000,250000),
                                labels = c('<50K','50K-100K','100K-150K','+150K'))
    ) %>%
    filter(id<n_day*25) %>% 
    select(-c(id,prediction,creditscore,age,tenure,balance,estimatedsalary)) 

  
  return(df_test)
}


get_dist <- function(train,test,var){
  
  final_data <- 
    list(train=train,test=test) %>%
    map(~ .x %>%
          group_by(!! parse_expr(var)) %>%
          summarise(n=n()) %>%
          mutate(prop=round(n/sum(n),2))
    ) %>%
    map2(.,names(.),~.x %>% mutate(type=.y)) %>%
    bind_rows() %>% 
    select(-n)
  
  return(final_data)
}


draw_dist <- function(df){
  
   var <- names(df)[1]
   
   hchart(df,title='Distribution',
          "column",
          hcaes(x = !! sym(var) , y = prop, group = type),
          color = c("#7CB5EC", "#F7A35C")
   ) %>% 
     hc_legend(align='left',verticalAlign = "top") %>% 
     hc_xAxis(
       title = list(text = NULL))
 }


draw_density <- function(train_probs,test_probs){
  
  
  hchart(title='ddss',
    density(train_probs$probs,from = 0,to = 1),
    type = "area", 
    name = "Base Sample ",
    color='#7CB5EC'
  ) %>%
    hc_add_series(
      density(test_probs$prediction_proba,from = 0,to = 1),
      type = "area",
      color='#F7A35C',
      name = "Recent Sample"
    )
}


get_table <- function(train,test,var){
  
  get_dist(train,test,var) %>% 
    pivot_wider(names_from = 'type',values_from = 'prop') %>% 
    mutate(diff=train-test,
           ln_diff=round(log(train/test),2),
           PSI=round(diff*ln_diff,2)
    )
}


connect_db <- function(){
    
  mydb <-
    dbConnect(
      MySQL(),
      user = db_user,
      password = db_pass,
      dbname = db_name,
      host = db_host,
      port = db_port
    )
  assign('mydb', mydb, envir = .GlobalEnv)
}


valueBoxSpark <- function(value, title, sparkobj = NULL, subtitle, info = NULL, 
                          icon = NULL, color = "aqua", width = 4, href = NULL){
  
  shinydashboard:::validateColor(color)
  
  if (!is.null(icon))
    shinydashboard:::tagAssert(icon, type = "i")
  
  info_icon <- tags$small(
    tags$i(
      class = "fa fa-info-circle fa-lg",
      title = info,
      `data-toggle` = "tooltip",
      style = "color: rgba(255, 255, 255, 0.75);"
    ),
    # bs3 pull-right 
    # bs4 float-right
    class = "pull-right float-right"
  )
  
  boxContent <- div(
    class = paste0("small-box bg-", color),
    div(
      class = "inner",
      tags$small(title),
      if (!is.null(sparkobj)) info_icon,
      h3(value),
      if (!is.null(sparkobj)) sparkobj,
      p(subtitle)
    ),
    # bs3 icon-large
    # bs4 icon
    if (!is.null(icon)) div(class = "icon-large icon", icon, style = "z-index; 0")
  )
  
  if (!is.null(href)) 
    boxContent <- a(href = href, boxContent)
  
  div(
    class = if (!is.null(width)) paste0("col-sm-", width), 
    boxContent
  )
}


get_boxdf <- function(test){
  df<-
    test %>% 
    tibble() %>% 
    select(prediction_proba,prediction_time) %>% 
    mutate(prediction_time=as.Date(prediction_time),
           prediction_time=sample(seq(Sys.Date()-20,by='day',length=20),size = nrow(.),replace = TRUE)
    ) %>% 
    arrange(prediction_time) %>% 
    mutate(n=1) %>% 
    group_by(prediction_time) %>% 
    summarise(proba=round(mean(prediction_proba),2),
              n=sum(n))
  
  return(df)
}


get_boxdf1 <- function(test){
  df<-
    test %>% 
    tibble() %>% 
    select(prediction_proba,prediction_time) %>% 
    mutate(prediction_date=as.Date(prediction_time)
    ) #%>% 
    # arrange(prediction_time) %>% 
    # group_by(prediction_time) %>% 
    # summarise(proba=round(mean(prediction_proba),2),
    #           n=n())
  
  return(df)
}
