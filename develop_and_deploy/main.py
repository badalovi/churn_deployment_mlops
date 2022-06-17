import models
import pandas as pd
from utils import get_from_s3, get_prediction, insert_data
import os
import boto3
import pickle
import logging
from dotenv import load_dotenv

from database import engine, get_db
from sqlalchemy.orm import Session
from fastapi import FastAPI, Depends, Request
from schemas import Churn, ChurnDriftInput


model = get_from_s3('mlopssbucket','rf-estimator')

# Creates all the tables defined in models module
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.post("/prediction/churn")
async def predict_churn(req: Churn,  db: Session = Depends(get_db)):
    pred = get_prediction(model=model,request=req.dict())[0]
    proba = get_prediction(model=model,request=req.dict())[1]
    db_record = insert_data(request=req.dict(),
                            prediction=pred,
                            proba=proba,
                            db=db
                            )
    return {"prediction": pred, 'probability': proba, "db_record": db_record}
