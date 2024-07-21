#Import necessary modules to support api creation.
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import joblib
import numpy as np
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional

# Load the trained model
model = joblib.load("vehicle_co2_emission_model.joblib")

# Label encoder mappings (assuming these were the mappings from the training script)
vehicle_class_mapping = {
    "COMPACT": 0,
    "MID-SIZE": 1,
    "MINICOMPACT": 2,
    "SUBCOMPACT": 3,
    "SUV - SMALL": 4,
    "TWO-SEATER": 5,
}
transmission_mapping = {"A6": 0, "AS5": 1, "AS6": 2, "AV7": 3, "M6": 4, "AM7": 5}
fuel_type_mapping = {"Z": 0}


class InputData(BaseModel):
    VEHICLECLASS: str
    ENGINESIZE: float
    CYLINDERS: int
    TRANSMISSION: str
    FUELTYPE: str
    FUELCONSUMPTION_CITY: float
    FUELCONSUMPTION_HWY: float
    FUELCONSUMPTION_COMB: float
    FUELCONSUMPTION_COMB_MPG: float


def convertRequestToModelValue(data: dict) -> list:
    data["VEHICLECLASS"] = vehicle_class_mapping[data["VEHICLECLASS"]]
    data["TRANSMISSION"] = transmission_mapping[data["TRANSMISSION"]]
    data["FUELTYPE"] = fuel_type_mapping[data["FUELTYPE"]]
    return list(data.values())


# Initialize FastAPI
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"message": "Welcome to the Vehicle CO2 Emission Prediction API"}


@app.post("/predict")
def predict(data: InputData):
    # Convert input data to the required format for the model
    input_data = [convertRequestToModelValue(data.dict())]

    # Making prediction
    prediction = model.predict(input_data)
    print(prediction[0])

    # Returning the prediction as a response
    return {"prediction": round(prediction[0], 0)}
