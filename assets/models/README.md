# Emotion Model Directory

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
