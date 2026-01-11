import tensorflow as tf
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

# ===== STEP 1: Load and Preprocess Dataset =====
df = pd.read_csv("augmented_crop_suggestion_dataset.csv")  # Replace with your dataset

# Clean column names
df.rename(columns=lambda x: x.strip().lower(), inplace=True)

# Encode categorical variables
label_encoders = {}
for column in ["season", "land type", "soil type", "water source", "previous crop", "suggested crop"]:
    label_encoders[column] = LabelEncoder()
    df[column] = label_encoders[column].fit_transform(df[column])

# Features and target
X = df.drop(columns=["suggested crop"])
y = df["suggested crop"]

# Normalize land size
scaler = StandardScaler()
X["land size"] = scaler.fit_transform(X[["land size"]])

# Split dataset into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# ===== STEP 2: Build TensorFlow Model =====
model = tf.keras.Sequential([
    tf.keras.layers.Dense(16, activation='relu', input_shape=(X.shape[1],)),
    tf.keras.layers.Dense(8, activation='relu'),
    tf.keras.layers.Dense(len(label_encoders["suggested crop"].classes_), activation='softmax')  # Output layer
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Train the model
model.fit(X_train, y_train, epochs=50, batch_size=16, verbose=1)

# ===== STEP 3: Evaluate Model Accuracy =====
loss, accuracy = model.evaluate(X_test, y_test, verbose=1)
print(f"🔥 Model Accuracy: {accuracy * 100:.2f}%")

# ===== STEP 4: Convert Model to TFLite Format =====
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open("final_crop_suggestion_model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Model saved as 'crop_suggestion_model.tflite'")
