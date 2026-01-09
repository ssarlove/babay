#!/usr/bin/env python3
"""
Download Script for Baby Care App Emotion Model
Downloads a pre-trained TensorFlow Lite emotion detection model and sets up assets.

This script downloads a FER-2013 based emotion recognition model trained on:
- angry, disgust, fear, happy, sad, surprise, neutral

Requirements:
    pip install requests tensorflow

Usage:
    python download_emotion_model.py
"""

import os
import requests
import zipfile
import io
import shutil
from pathlib import Path

# Configuration
PROJECT_ROOT = Path(__file__).parent
ASSETS_DIR = PROJECT_ROOT / "assets"
MODELS_DIR = ASSETS_DIR / "models"

# Model sources - trying multiple sources in order of preference
MODEL_SOURCES = [
    {
        "name": "HuggingFace Emo0.1",
        "url": "https://huggingface.co/shivamprasad1001/Emo0.1/resolve/main/emotion_model.h5",
        "convert": True,  # Need to convert from H5 to TFLite
    },
    {
        "name": "GitHub Raw Model",
        "url": "https://raw.githubusercontent.com/Shubham-Zone/Emotion-detection-using-tflite/main/assets/model_unquant.tflite",
        "convert": False,
    },
    {
        "name": "Alternative GitHub Model",
        "url": "https://github.com/neta000/emotion_detection_model/raw/main/emotion_model.tflite",
        "convert": False,
    },
]

LABELS = ["angry", "disgust", "fear", "happy", "sad", "surprise", "neutral"]


def create_directories():
    """Create necessary directories for the project."""
    print("Creating directory structure...")
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    print(f"  Created: {MODELS_DIR}")


def download_file(url, destination, source_name):
    """Download a file from a URL."""
    print(f"\nAttempting to download from {source_name}...")
    print(f"  URL: {url}")
    
    try:
        response = requests.get(url, timeout=60, stream=True)
        response.raise_for_status()
        
        total_size = int(response.headers.get('content-length', 0))
        print(f"  File size: {total_size / 1024:.2f} KB")
        
        with open(destination, 'wb') as f:
            downloaded = 0
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
                downloaded += len(chunk)
                if total_size > 0:
                    percent = (downloaded / total_size) * 100
                    print(f"\r  Downloading: {percent:.1f}%", end="", flush=True)
        
        print(f"\n  Downloaded successfully: {destination}")
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"  Failed to download: {e}")
        return False


def create_labels_file():
    """Create the labels.txt file for emotion labels."""
    labels_file = ASSETS_DIR / "labels.txt"
    print(f"\nCreating labels file: {labels_file}")
    
    with open(labels_file, 'w') as f:
        for label in LABELS:
            f.write(f"{label}\n")
    
    print(f"  Created labels.txt with {len(LABELS)} emotions: {', '.join(LABELS)}")
    return True


def create_placeholder_model():
    """
    Create a placeholder model file if download fails.
    This creates a minimal TFLite model that can be used for testing.
    """
    print("\nCreating placeholder model...")
    
    try:
        import tensorflow as tf
        
        # Create a simple model architecture for emotion detection
        model = tf.keras.Sequential([
            tf.keras.layers.Conv2D(32, (3, 3), activation='relu', input_shape=(48, 48, 3)),
            tf.keras.layers.MaxPooling2D((2, 2)),
            tf.keras.layers.Conv2D(64, (3, 3), activation='relu'),
            tf.keras.layers.MaxPooling2D((2, 2)),
            tf.keras.layers.Flatten(),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dense(7, activation='softmax')
        ])
        
        # Compile model
        model.compile(
            optimizer='adam',
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        # Convert to TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        tflite_model = converter.convert()
        
        # Save model
        model_path = MODELS_DIR / "emotion_model.tflite"
        with open(model_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"  Created placeholder model: {model_path}")
        print(f"  Model size: {len(tflite_model) / 1024:.2f} KB")
        print("\n  NOTE: This is a randomly initialized model for testing.")
        print("  For real emotion detection, download a pre-trained FER-2013 model.")
        
        return True
        
    except ImportError:
        print("  TensorFlow not installed. Creating minimal TFLite file...")
        
        # Create a minimal valid TFLite file (empty model for placeholder)
        model_path = MODELS_DIR / "emotion_model.tflite"
        
        # This is a minimal valid TFLite model header
        minimal_tflite = bytes([
            0x54, 0x46, 0x4C, 0x54, 0x03, 0x00, 0x00, 0x00,  # Magic number + version
            0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  # Data type
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  # Placeholder
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        ])
        
        with open(model_path, 'wb') as f:
            f.write(minimal_tflite)
        
        print(f"  Created placeholder file: {model_path}")
        print("  Install TensorFlow to create a proper model:")
        print("    pip install tensorflow")
        
        return True


def download_model():
    """Try to download model from available sources."""
    create_directories()
    
    # First, try to download a real pre-trained model
    for source in MODEL_SOURCES:
        if not source["convert"]:  # Skip sources requiring conversion for now
            model_path = MODELS_DIR / "emotion_model.tflite"
            
            if download_file(source["url"], model_path, source["name"]):
                return True
    
    # If download fails, create a placeholder
    print("\nCould not download pre-trained model.")
    print("Creating a placeholder model for testing...")
    return create_placeholder_model()


def create_sample_images_folder():
    """Create a README in the models directory."""
    readme_path = MODELS_DIR / "README.md"
    
    readme_content = """# Emotion Model Directory

This directory contains the TensorFlow Lite emotion detection model.

## Model Information
- **Type**: TensorFlow Lite (TFLite)
- **Input Size**: 48x48 pixels (grayscale, converted to RGB)
- **Output**: 7 emotion classes
  - angry
  - disgust
  - fear
  - happy
  - sad
  - surprise
  - neutral

## Usage
The model is loaded by the `EmotionDetector` class in `lib/services/emotion_detector.dart`.

## Training Data
This model is typically trained on the FER-2013 dataset.

## Downloading a Pre-trained Model
If you need a production-ready model:
1. Download from TensorFlow Hub
2. Train your own using the FER-2013 dataset
3. Convert a Keras/H5 model to TFLite format

## Performance Notes
- First inference may take longer (model loading)
- Subsequent inferences are faster
- Consider using a smaller model for real-time processing
"""
    
    with open(readme_path, 'w') as f:
        f.write(readme_content)
    
    print(f"  Created README: {readme_path}")


def print_summary():
    """Print a summary of what was created."""
    print("\n" + "="*60)
    print("SETUP COMPLETE")
    print("="*60)
    print(f"\nAssets directory: {ASSETS_DIR}")
    print(f"Models directory: {MODELS_DIR}")
    
    # List files
    print("\nCreated files:")
    for file_path in ASSETS_DIR.rglob("*"):
        if file_path.is_file():
            size = file_path.stat().st_size
            print(f"  - {file_path.relative_to(PROJECT_ROOT)} ({size} bytes)")
    
    print("\nEmotion labels:")
    for i, label in enumerate(LABELS, 1):
        print(f"  {i}. {label}")
    
    print("\nNext steps:")
    print("1. If a placeholder model was created, download a real model for production")
    print("2. Run your Flutter app: flutter run")
    print("3. The app will work in demo mode with placeholder model")
    print("="*60)


def main():
    """Main function to download and set up the emotion model."""
    print("="*60)
    print("Baby Care App - Emotion Model Setup")
    print("="*60)
    
    # Change to script directory
    os.chdir(PROJECT_ROOT)
    print(f"\nWorking directory: {PROJECT_ROOT}")
    
    # Create directories
    create_directories()
    
    # Create labels file
    create_labels_file()
    
    # Download or create model
    download_model()
    
    # Create README
    create_sample_images_folder()
    
    # Print summary
    print_summary()


if __name__ == "__main__":
    main()