import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/emotion_result.dart';

class StorageService extends ChangeNotifier {
  late Box<dynamic> _preferencesBox;
  late Box<EmotionResult> _historyBox;
  
  // Preferences keys
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _useNightModeKey = 'use_night_mode';
  static const String _saveHistoryKey = 'save_history';
  static const String _showConfidenceKey = 'show_confidence';
  static const String _autoAnalyzeKey = 'auto_analyze';
  static const String _firstLaunchKey = 'first_launch';

  StorageService() {
    _init();
  }

  Future<void> _init() async {
    _preferencesBox = Hive.box('baby_care_preferences');
    _historyBox = Hive.box<EmotionResult>('mood_history');
    notifyListeners();
  }

  // Dark mode
  bool get isDarkMode => _preferencesBox.get(_isDarkModeKey, defaultValue: true) as bool;
  set isDarkMode(bool value) {
    _preferencesBox.put(_isDarkModeKey, value);
    notifyListeners();
  }

  // Night mode (red tint)
  bool get useNightMode => _preferencesBox.get(_useNightModeKey, defaultValue: false) as bool;
  set useNightMode(bool value) {
    _preferencesBox.put(_useNightModeKey, value);
    notifyListeners();
  }

  // Save history preference
  bool get saveHistory => _preferencesBox.get(_saveHistoryKey, defaultValue: true) as bool;
  set saveHistory(bool value) {
    _preferencesBox.put(_saveHistoryKey, value);
    notifyListeners();
  }

  // Show confidence score
  bool get showConfidence => _preferencesBox.get(_showConfidenceKey, defaultValue: true) as bool;
  set showConfidence(bool value) {
    _preferencesBox.put(_showConfidenceKey, value);
    notifyListeners();
  }

  // Auto-analyze mode
  bool get autoAnalyze => _preferencesBox.get(_autoAnalyzeKey, defaultValue: false) as bool;
  set autoAnalyze(bool value) {
    _preferencesBox.put(_autoAnalyzeKey, value);
    notifyListeners();
  }

  // First launch check
  bool get isFirstLaunch => _preferencesBox.get(_firstLaunchKey, defaultValue: true) as bool;
  set isFirstLaunch(bool value) {
    _preferencesBox.put(_firstLaunchKey, value);
  }

  // History operations
  List<EmotionResult> getHistory() {
    return _historyBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveEmotionResult(EmotionResult result) async {
    if (saveHistory) {
      await _historyBox.add(result);
      notifyListeners();
    }
  }

  Future<void> deleteHistoryEntry(EmotionResult result) async {
    await result.delete();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
    notifyListeners();
  }

  // Get emotion statistics
  Map<String, int> getEmotionStats() {
    final history = getHistory();
    final stats = <String, int>{};
    
    for (final result in history) {
      stats[result.dominantEmotion] = (stats[result.dominantEmotion] ?? 0) + 1;
    }
    
    return stats;
  }

  // Get recent trends (last 24 hours)
  Map<String, int> getRecentTrends() {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(hours: 24));
    
    final recentHistory = getHistory()
        .where((r) => r.timestamp.isAfter(dayAgo));
    
    final stats = <String, int>{};
    for (final result in recentHistory) {
      stats[result.dominantEmotion] = (stats[result.dominantEmotion] ?? 0) + 1;
    }
    
    return stats;
  }
}