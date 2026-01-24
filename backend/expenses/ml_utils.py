import pickle
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "ml", "expense_category_model.pkl")

# Load model once
with open(MODEL_PATH, "rb") as f:
    category_model = pickle.load(f)


def predict_category(description: str) -> str:
    """
    Predict expense category using trained ML model
    """
    if not description:
        return "Others"

    prediction = category_model.predict([description])
    return prediction[0]
