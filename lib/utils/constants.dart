class AppConstants {
  // ML Model settings
  static const String emotionModelPath = 'assets/models/emotion_model.tflite';
  static const int modelInputSize = 48;
  
  // Analysis settings
  static const double minConfidenceThreshold = 0.6;
  static const int maxRetries = 3;
  
  // Storage keys
  static const String preferencesBox = 'baby_care_preferences';
  static const String historyBox = 'mood_history';
  
  // Animation durations
  static const Duration scanAnimationDuration = Duration(seconds: 2);
  static const Duration resultAnimationDuration = Duration(milliseconds: 300);
}