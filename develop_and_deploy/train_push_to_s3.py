import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

import os
import boto3
import pickle
import logging
from dotenv import load_dotenv


# read data
df = pd.read_csv("https://raw.githubusercontent.com/erkansirin78/datasets/master/Churn_Modelling.csv")
print(df.head(2))
print('Null observations: ','\n',df.isnull().sum())


# Preparing Dataset
df_clean = df.iloc[:, 3:]
df_final = pd.get_dummies(df_clean, drop_first=True)
df_final.columns = df_final.columns.str.lower()
col_names = df_final.columns
order = [8,0,1,2,3,4,5,6,7,9,10,11]
col_names = [col_names[i] for i in order]
df_final = df_final[col_names]
print("------------- \nFinal Dataset")
print(df_final.head(2))


# Feature matrix
X = df_final.iloc[:, 1:].values
print(X.shape)
print(X[0:2])


# Output variable
y = df_final.iloc[:, 0]
print(y.shape)
print(y[:6])


# split test train
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=76)

estimator = RandomForestClassifier(n_estimators=250)
estimator.fit(X_train, y_train)


push_to_s3(estimator, 'mlopssbucket', 'rf-estimator')
