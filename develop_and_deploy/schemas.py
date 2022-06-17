from pydantic import BaseModel

class Churn(BaseModel):
    creditscore: int
    age: int
    tenure: int
    balance: int
    numofproducts: int
    hascrcard: int
    isactivemember: int
    estimatedsalary: float
    geography: str
    gender: str

    class Config:
        schema_extra = {
            "example": {
                "creditscore": 619,
                "age": 42,
                "tenure": 2,
                "balance": 0,
                "numofproducts": 1,
                "hascrcard": 1,
                "isactivemember": 1,
                "estimatedsalary": 101348,
                "geography": "France",
                "gender": "Female",
            }
        }


class ChurnDriftInput(BaseModel):
    n_days_before: int

    class Config:
        schema_extra = {
            "example": {
                "n_days_before": 5,
            }
        }