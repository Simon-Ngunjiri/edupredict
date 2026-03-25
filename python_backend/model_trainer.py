import pandas as pd
import numpy as np
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

# Load data
data = pd.read_csv(r"C:\dev\other_project\first_app\python_backend\dataset\ultimate_student_productivity_dataset_5000.csv")

print("Dataset loaded successfully!")
print(f"Shape: {data.shape}")
print(f"Columns: {list(data.columns)}")

# Preprocess data
data['internet_quality'] = data['internet_quality'].map({'Poor': 0, 'Average': 1, 'Good': 2})
data['exam_score'] = data['exam_score'].apply(lambda x: 1 if x >= 50 else 0)

# Define features and target
features = ['study_hours', 'self_study_hours', 'online_classes_hours', 'mental_health_score']
X = data[features]
y = data['exam_score']

print(f"\nFeatures: {features}")
print(f"Target distribution:\n{y.value_counts()}")

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, train_size=0.2, random_state=42)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train model
model = LogisticRegression()
model.fit(X_train_scaled, y_train)

# Evaluate model
y_pred = model.predict(X_test_scaled)
accuracy = accuracy_score(y_test, y_pred)

print(f"\n{'='*50}")
print(f"Model Training Complete!")
print(f"Accuracy: {accuracy*100:.2f}%")
print(f"\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))
print(f"\nClassification Report:")
print(classification_report(y_test, y_pred))

# Feature importance
importance = pd.DataFrame({
    'feature': features,
    'coefficient': model.coef_[0]
}).sort_values('coefficient', key=abs, ascending=False)

print(f"\nFeature Importance:")
print(importance)

# Save model and scaler
joblib.dump(model, 'logistic_model.joblib')
joblib.dump(scaler, 'scaler.joblib')

print(f"\n{'='*50}")
print("Model saved as 'logistic_model.joblib'")
print("Scaler saved as 'scaler.joblib'")
print("Run 'uvicorn main:app --reload' to start the API server!")