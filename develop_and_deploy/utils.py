import models
import os
import boto3
import pickle
import logging
from dotenv import load_dotenv


def gender_encoder(gender):
    val = 0

    if gender == 'Male':
        val = 1
    else:
        val = val

    return val


def geography_encoder(geography):
    val1 = 0
    val2 = 0

    if geography == 'Germany':
        val1 = 1
        val2 = 0
    elif geography == 'Spain':
        val1 = 0
        val2 = 1
    else:
        val1 = val1
        val2 = val2

    return val1, val2


def get_prediction(model, request):

    creditscore=request['creditscore']
    age = request["age"]
    tenure = request["tenure"]
    balance = request["balance"]
    numofproducts = request["numofproducts"]
    hascrcard = request["hascrcard"]
    isactivemember = request["isactivemember"]
    estimatedsalary = request["estimatedsalary"]
    geography = geography_encoder(request["geography"])
    gender = gender_encoder(request["gender"])

    full_data = [[creditscore, age, tenure, balance, numofproducts,
                  hascrcard, isactivemember, estimatedsalary,
                  geography[0],geography[1], gender]]

    pred = model.predict(full_data).tolist()[0]
    prob = model.predict_proba(full_data)[0][1]

    return [pred,prob]



def insert_data(request, prediction, proba, db):
    new_data = models.Churn(

        creditscore=request['creditscore'],
        age=request["age"],
        tenure=request["tenure"],
        balance=request["balance"],
        numofproducts=request["numofproducts"],
        hascrcard=request["hascrcard"],
        isactivemember=request["isactivemember"],
        estimatedsalary=request["estimatedsalary"],
        geography=request["geography"],
        gender=request["gender"],
        prediction_proba=proba,
        prediction=prediction
    )

    db.add(new_data)
    db.commit()
    db.refresh(new_data)
    return new_data


def push_to_s3(model, bucket, key):

    # Reading Key and Secret
    load_dotenv()
    key_id = os.getenv('AWS_KEYID')
    secret = os.getenv('AWS_PASS')

    s3_res = boto3.resource(
        's3',
        aws_access_key_id=key_id,
        aws_secret_access_key=secret
    )

    client = boto3.client(
        's3',
        aws_access_key_id=key_id,
        aws_secret_access_key=secret
    )

    ''' Store pickle as a buffer, then save buffer to s3'''
    try:
        pickle_byte_obj = pickle.dumps(model)
        s3_res.Object(bucket, key).put(Body=pickle_byte_obj)
        logging.info(f'{key} saved to s3 bucket {bucket}')
    except Exception as e:
        raise logging.exception(e)


def get_from_s3(bucket, key):
    # Reading Key and Secret
    load_dotenv()
    key_id = os.getenv('AWS_KEYID')
    secret = os.getenv('AWS_PASS')

    s3_res = boto3.resource(
        's3',
        aws_access_key_id=key_id,
        aws_secret_access_key=secret
    )

    client = boto3.client(
        's3',
        aws_access_key_id=key_id,
        aws_secret_access_key=secret
    )

    ''' Get pickle as a buffer, then push it as object'''
    try:
        object = client.get_object(Bucket=bucket, Key=key)
        serializedObject = object['Body'].read()
        model = pickle.loads(serializedObject)
        logging.info(f'{key} saved to s3 bucket {bucket}')
        return model
    except Exception as e:
        raise logging.exception(e)

