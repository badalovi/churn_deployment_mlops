from database import Base
from sqlalchemy import Column, String, Integer, Float, DateTime
from sqlalchemy.sql import func


class Churn(Base):
    __tablename__ = "churn"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, autoincrement=True, primary_key=True)
    creditscore = Column(Integer)
    age = Column(Integer)
    tenure = Column(Integer)
    balance = Column(Float)
    numofproducts = Column(Integer)
    hascrcard = Column(Integer)
    isactivemember = Column(Integer)
    estimatedsalary = Column(Float)
    geography = Column(String(20))
    gender = Column(String(10))
    prediction = Column(Float)
    prediction_proba = Column(Float)
    prediction_time = Column(DateTime(timezone=True), server_default=func.now())
    #client_ip = Column(String(20))
