from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
import joblib
import numpy as np
import pandas as pd
import os

app = FastAPI(
    title="Student Productivity API",
    description="ML-powered API to predict exam scores and provide wellness alerts",
    version="1.0.0"
)

# Load model and scaler
MODEL_PATH = "C:/dev/other_project/first_app/python_backend/logistic_model.joblib"
SCALER_PATH = "scaler.joblib"

def load_model():
    """Load the trained model and scaler"""
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError("Model not found. Run model_trainer.py first!")
    return joblib.load(MODEL_PATH), joblib.load(SCALER_PATH)

try:
    model, scaler = load_model()
    print("Model loaded successfully!")
except FileNotFoundError:
    model, scaler = None, None
    print("Warning: Model not found. Please train the model first.")

# Pydantic models for request/response
class StudentInput(BaseModel):
    study_hours: float = Field(..., ge=0, le=24, description="Hours studied today")
    self_study_hours: float = Field(..., ge=0, le=24, description="Hours of self-study today")
    online_classes_hours: float = Field(..., ge=0, le=24, description="Hours for online classes today")
    social_media_hours: float = Field(..., ge=0, le=24, description="Hours spent on social media today")
    gaming_hours: float = Field(..., ge=0, le=24, description="Hours spent gaming today")
    sleep_hours: float = Field(..., ge=0, le=24, description="Hours slept today")
    screen_time_hours: float = Field(..., ge=0, le=24, description="Hours spent on screen today")
    exercise_minutes: int = Field(..., ge=0, description="Minutes spent exercising today")
    caffeine_intake_mg: int = Field(..., ge=0, description="Mg of caffeine consumed today")
    part_time_job: int = Field(..., ge=0, description="Number of part-time jobs today")
    upcoming_deadline: int = Field(..., ge=0, description="Number of upcoming deadlines")
    internet_quality: str = Field(..., description="Internet quality (Poor/Average/Good)")
    mental_health_score: int = Field(..., ge=1, le=10, description="Mental health score (1-10)")
    focus_index: float = Field(..., ge=0, description="Focus index today")
    burnout_level: float = Field(..., ge=0, description="Burnout level today")
    productivity_score: float = Field(..., ge=0, description="Productivity score today")

class PredictionResponse(BaseModel):
    exam_pass_probability: float
    exam_fail_probability: float
    predicted_outcome: str
    alerts: List[str]
    input_summary: dict

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    message: str

@app.get("/", tags=["Health"])
async def root():
    """Root endpoint - API health check"""
    return {
        "status": "online",
        "message": "Student Productivity API is running",
        "version": "1.0.0"
    }

@app.get("/health", tags=["Health"])
async def health_check() -> HealthResponse:
    """Check if the API and model are healthy"""
    return HealthResponse(
        status="healthy" if model is not None else "unhealthy",
        model_loaded=model is not None,
        message="Model loaded successfully" if model is not None else "Model not found. Run model_trainer.py first."
    )

@app.post("/predict", response_model=PredictionResponse, tags=["Prediction"])
async def predict_exam_score(input_data: StudentInput):
    """
    Predict exam score probability and generate alerts based on student input.
    
    Send all required parameters and receive:
    - Exam pass/fail probabilities
    - Personalized alerts for improvement
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded. Please train the model first.")
    
    # Map internet quality
    internet_quality_map = {'poor': 0, 'average': 1, 'good': 2}
    internet_quality = internet_quality_map.get(input_data.internet_quality.lower(), 1)
    
    # Prepare input for model (only features used in training)
    student_features = np.array([[
        input_data.study_hours,
        input_data.self_study_hours,
        input_data.online_classes_hours,
        input_data.mental_health_score
    ]])
    
    # Scale features
    student_scaled = scaler.transform(student_features)
    
    # Get prediction probabilities
    probabilities = model.predict_proba(student_scaled)[0]
    pass_prob = probabilities[1]
    fail_prob = probabilities[0]
    
    # Determine predicted outcome
    predicted_outcome = "Pass" if pass_prob >= 0.5 else "Fail"
    
    # Generate alerts
    alerts = []
    
    if input_data.study_hours == 0:
        alerts.append("You haven't studied today. Try to study to increase your exam scores.")
    
    if input_data.sleep_hours < 6:
        alerts.append("You slept less than 6 hours. Proper sleep improves focus and exam scores.")
    
    if input_data.gaming_hours > 5:
        alerts.append("High gaming detected. Reduce gaming to increase your productivity.")
    
    if input_data.mental_health_score < 5:
        alerts.append("Your mental health is not good. Relax a little bit or seek help to improve your mental wellness and exam scores.")
    
    if pass_prob < 0.7:
        alerts.append(f"Your exam score probability is only {pass_prob*100:.2f}%. Consider improving your study habits today.")
    
    # Create input summary for response
    input_summary = {
        "study_hours": input_data.study_hours,
        "self_study_hours": input_data.self_study_hours,
        "online_classes_hours": input_data.online_classes_hours,
        "mental_health_score": input_data.mental_health_score,
        "internet_quality": input_data.internet_quality,
        "sleep_hours": input_data.sleep_hours,
        "gaming_hours": input_data.gaming_hours
    }
    
    return PredictionResponse(
        exam_pass_probability=round(pass_prob, 4),
        exam_fail_probability=round(fail_prob, 4),
        predicted_outcome=predicted_outcome,
        alerts=alerts,
        input_summary=input_summary
    )

@app.get("/model/info", tags=["Model"])
async def get_model_info():
    """Get information about the loaded model"""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    return {
        "model_type": type(model).__name__,
        "features_used": ["study_hours", "self_study_hours", "online_classes_hours", "mental_health_score"],
        "target_variable": "exam_score",
        "model_path": MODEL_PATH,
        "scaler_path": SCALER_PATH
    }