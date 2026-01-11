import tensorflow as tf
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

# ===== STEP 1: Load and Preprocess Dataset =====
df = pd.read_csv("crop_maintenance_summarized.csv")

# Drop the maintenance summary (not used for prediction)
df.drop(columns=["Maintenance Details"], inplace=True)

# Encode categorical variables
label_encoders = {}
for col in ["Soil Moisture Level", "Weather Forecast", "Disease Presence", "Crop Type"]:
    label_encoders[col] = LabelEncoder()
    df[col] = label_encoders[col].fit_transform(df[col])

# Features and target
X = df.drop(columns=["Crop Type"])
y = df["Crop Type"]

# Normalize the numeric column
scaler = StandardScaler()
X["Growth Day"] = scaler.fit_transform(X[["Growth Day"]])

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# ===== STEP 2: Build TensorFlow Model =====
model = tf.keras.Sequential([
    tf.keras.layers.Dense(16, activation='relu', input_shape=(X.shape[1],)),
    tf.keras.layers.Dense(8, activation='relu'),
    tf.keras.layers.Dense(len(label_encoders["Crop Type"].classes_), activation='softmax')
])

model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Train the model
model.fit(X_train, y_train, epochs=50, batch_size=16, verbose=1)

# ===== STEP 3: Evaluate Model =====
loss, accuracy = model.evaluate(X_test, y_test, verbose=1)
print(f"🔥 Model Accuracy: {accuracy * 100:.2f}%")

# ===== STEP 4: Convert to TFLite Format =====
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open("final_crop_maintenance_model.tflite", "wb") as f:
    f.write(tflite_model)

print("✅ Model saved as 'final_crop_maintenance_model.tflite'")