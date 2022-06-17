FROM rocker/tidyverse:4.0

RUN apt-get update && apt-get install -y \
  libcurl4-gnutls-dev \
  libcairo2-dev \
  libxt-dev \
  libssl-dev \
  libssh2-1-dev \
  libglpk-dev

# system library dependency 
RUN apt-get update && apt-get install -y \
  libmpfr-dev \
  libxml2-dev

RUN apt-get -y install libxml2-dev libssl-dev libcurl4-openssl-dev

RUN R -e 'install.packages(c("shiny","shinydashboard","shiny","highcharter","formattable","lubridate","jsonlite","shinymanager","RMySQL"))'
COPY app.R /app.R
COPY prep.R /prep.R
COPY utils.R /utils.R
COPY df_train.csv /df_train.csv
COPY df_proba.csv /df_proba.csv
COPY .Renviron /.Renviron

EXPOSE 3838
CMD R -e 'shiny::runApp("app.R", port = 3838, host = "0.0.0.0")'
