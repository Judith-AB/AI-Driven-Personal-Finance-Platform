import pandas as pd
import pickle

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

# Load dataset
data = pd.read_csv("expense_data.csv")

X = data["description"]
y = data["category"]

#ML pipeline
model = Pipeline([
    ("tfidf", TfidfVectorizer(stop_words="english")),
    ("classifier", MultinomialNB())
])

# Train model
model.fit(X, y)

# Save trained model
with open("expense_category_model.pkl", "wb") as f:
    pickle.dump(model, f)

print("Model trained and saved successfully!")
