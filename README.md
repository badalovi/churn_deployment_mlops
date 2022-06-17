## Churn Model Deployment in MLOps Scope 

### Overview
I developed this end-to-end MLOps project which uses modern MLOps approaches and
tech stack. The primary objective of it is to make the end
user able to get the churn prediction via an endpoint when posting its required data
while Data Science team can monitor the model on a particularly developed app
serving on another endpoint. 
<p>The project consists of two different parts in the first part of which includes
the whole model development and deployment process done in Python, while
the second part is a Shiny dashboard developed in R to monitor 
the model drift and other aspects of it.</p>

----------------------------------------------------------------------------

### How It Works
<img src="https://user-images.githubusercontent.com/63539469/174332865-dfbd963d-fb96-4cd1-8f96-451e00e0df6d.png" alt="drawing" width="700"/>

*Note: Each service is deployed in a docker container*

1. POST request is sent to an API of the running project on an AWS instance
2. Prediction is evaluated on the same endpoint.
3. All relevant data is written to mysql database running on the same instance.
4. Monitoring application running on another instance  connects to mysql database,
fetches the live data and demonstrates simultaneously.
----------------------------------------------------------------------------

### Tech Stack
- Docker
- Linux Cmd
- Git
- AWS
  - S3
  - EC2
- Python
  - FastAPI
  - sqlalchemy
  - boto3
  - pydantic
  - sklearn
- R
  - shinydashboard
  - tidyverse
  - RMySQL
  - highcharter
  - formattable
----------------------------------------------------------------------------
### App
![app_gif_video_final](https://user-images.githubusercontent.com/63539469/174332705-a42bf0da-a284-4646-92a6-63de9a2a5686.gif)

