import pandas as pd
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

def train_expense_model(csv_path):
    # 1. Load dataset
    try:
        data = pd.read_csv(csv_path)
    except FileNotFoundError:
        print(f"Error: {csv_path} not found. Please ensure the CSV exists.")
        return

    data = data.dropna(subset=['description', 'category'])
    X = data["description"].str.lower()
    y = data["category"]

    
    model = Pipeline([
        ("tfidf", TfidfVectorizer(
            stop_words="english",
            analyzer='char_wb',  
            ngram_range=(2, 4),   
            lowercase=True
        )),
        ("classifier", MultinomialNB(alpha=0.1)) # alpha=0.1 helps with small data
    ])

    print(f"Training on {len(X)} samples...")
    model.fit(X, y)

    model_filename = "expense_category_model.pkl"
    with open(model_filename, "wb") as f:
        pickle.dump(model, f)

    print(f"Model trained and saved successfully as {model_filename}!")

if __name__ == "__main__":
    train_expense_model("expense_data.csv")