library(shinydashboard)
library(shiny)
library(highcharter)
library(tidyverse)
library(lubridate)
library(rlang)
library(formattable)
library(httr)
library(jsonlite)
library(shinymanager)
library(RMySQL)




# 1. Reading Data & Keys
df_train <- read_csv('df_train.csv')

shinyuser=Sys.getenv('shinyuser')
shinypass=Sys.getenv('shinypass')
db_user=Sys.getenv('db_user')
db_pass=Sys.getenv('db_pass')
db_name=Sys.getenv('db_name')
db_host=Sys.getenv('db_host')
db_port=as.integer(Sys.getenv('db_port'))



# 2. Defining Additional Objects

cols <- df_train %>% select(-c(exited,probs)) %>% colnames()
col_selects <- c("Geography","Gender","Number of Products", 
                 "Has Credit Card","Active Member", "Credit Score",
                 "Age", "Tenure","Balance","Estimated Salary")
names(cols) <- col_selects

sign_formatter <-
  formatter(
    "span",style = x ~ style(
      color = ifelse(x > 0, "green",ifelse(x < 0, "red", "black"))))


# 3. Define  Login Credentials
credentials <- data.frame(
  user = c(shinyuser),
  password = c(shinypass),
  start = c('2022-05-30'),
  expire = c(NA),
  admin = c(TRUE),
  stringsAsFactors = FALSE
)



