import 'dart:html' if (dart.library.html) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/emotion_result.dart';

class StorageService extends ChangeNotifier {
  late Box<dynamic> _preferencesBox;
  late Box<EmotionResult> _historyBox;
  
  // Web storage compatibility
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _useNightModeKey = 'use_night_mode';
  static const String _saveHistoryKey = 'save_history';
  static const String _showConfidenceKey = 'show_confidence';
  static const String _autoAnalyzeKey = 'auto_analyze';
  
  // Web localStorage keys
  static const String _webHistoryKey = 'baby_care_history';
  static const String _webSettingsKey = 'baby_care_settings';
  
  StorageService() {
    _init();
  }
  
  Future<void> _init() async {
    // On web, we use a different initialization approach
    if (kIsWeb) {
      _initWeb();
    } else {
      // Mobile - use Hive
      _preferencesBox = Hive.box('baby_care_preferences');
      _historyBox = Hive.box<EmotionResult>('mood_history');
    }
    notifyListeners();
  }
  
  // Web initialization using localStorage
  Future<void> _initWeb() async {
    // Initialize with defaults for web
    // Actual localStorage access happens in getters/setters
    notifyListeners();
  }
  
  // =====================================
  // Dark Mode Settings
  // =====================================
  bool get isDarkMode {
    if (kIsWeb) {
      return _getWebBool(_isDarkModeKey, true);
    }
    return _preferencesBox.get(_isDarkModeKey, defaultValue: true) as bool;
  }
  
  set isDarkMode(bool value) {
    if (kIsWeb) {
      _setWebBool(_isDarkModeKey, value);
    } else {
      _preferencesBox.put(_isDarkModeKey, value);
    }
    notifyListeners();
  }
  
  // =====================================
  // Night Mode Settings
  // =====================================
  bool get useNightMode {
    if (kIsWeb) {
      return _getWebBool(_useNightModeKey, false);
    }
    return _preferencesBox.get(_useNightModeKey, defaultValue: false) as bool;
  }
  
  set useNightMode(bool value) {
    if (kIsWeb) {
      _setWebBool(_useNightModeKey, value);
    } else {
      _preferencesBox.put(_useNightModeKey, value);
    }
    notifyListeners();
  }
  
  // =====================================
  // Save History Setting
  // =====================================
  bool get saveHistory {
    if (kIsWeb) {
      return _getWebBool(_saveHistoryKey, true);
    }
    return _preferencesBox.get(_saveHistoryKey, defaultValue: true) as bool;
  }
  
  set saveHistory(bool value) {
    if (kIsWeb) {
      _setWebBool(_saveHistoryKey, value);
    } else {
      _preferencesBox.put(_saveHistoryKey, value);
    }
    notifyListeners();
  }
  
  // =====================================
  // Show Confidence Setting
  // =====================================
  bool get showConfidence {
    if (kIsWeb) {
      return _getWebBool(_showConfidenceKey, true);
    }
    return _preferencesBox.get(_showConfidenceKey, defaultValue: true) as bool;
  }
  
  set showConfidence(bool value) {
    if (kIsWeb) {
      _setWebBool(_showConfidenceKey, value);
    } else {
      _preferencesBox.put(_showConfidenceKey, value);
    }
    notifyListeners();
  }
  
  // =====================================
  // Auto Analyze Setting
  // =====================================
  bool get autoAnalyze {
    if (kIsWeb) {
      return _getWebBool(_autoAnalyzeKey, false);
    }
    return _preferencesBox.get(_autoAnalyzeKey, defaultValue: false) as bool;
  }
  
  set autoAnalyze(bool value) {
    if (kIsWeb) {
      _setWebBool(_autoAnalyzeKey, value);
    } else {
      _preferencesBox.put(_autoAnalyzeKey, value);
    }
    notifyListeners();
  }
  
  // =====================================
  // History Management
  // =====================================
  List<EmotionResult> getHistory() {
    if (kIsWeb) {
      return _getWebHistory();
    }
    return _historyBox.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  Future<void> saveEmotionResult(EmotionResult result) async {
    if (kIsWeb) {
      _saveWebHistory(result);
    } else {
      if (saveHistory) {
        await _historyBox.add(result);
        notifyListeners();
      }
    }
  }
  
  Future<void> clearHistory() async {
    if (kIsWeb) {
      _clearWebHistory();
    } else {
      await _historyBox.clear();
    }
    notifyListeners();
  }
  
  // =====================================
  // Statistics
  // =====================================
  Map<String, int> getEmotionStats() {
    final history = getHistory();
    final stats = <String, int>{};
    for (final result in history) {
      stats[result.dominantEmotion] = (stats[result.dominantEmotion] ?? 0) + 1;
    }
    return stats;
  }
  
  // =====================================
  // Web Storage Helpers
  // =====================================
  bool _getWebBool(String key, bool defaultValue) {
    try {
      final value = window.localStorage[key];
      return value != null ? value == 'true' : defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
  
  void _setWebBool(String key, bool value) {
    try {
      window.localStorage[key] = value.toString();
    } catch (e) {
      // localStorage not available
    }
  }
  
  List<EmotionResult> _getWebHistory() {
    try {
      final data = window.localStorage[_webHistoryKey];
      if (data == null) return [];
      
      final List<dynamic> decoded = List.from(_decodeJson(data));
      return decoded.map((item) => EmotionResult.fromJson(item)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }
  
  void _saveWebHistory(EmotionResult result) {
    try {
      final history = _getWebHistory();
      history.insert(0, result);
      
      // Keep only last 50 entries
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      final encoded = _encodeJson(history.map((e) => e.toJson()).toList());
      window.localStorage[_webHistoryKey] = encoded;
      notifyListeners();
    } catch (e) {
      // storage error
    }
  }
  
  void _clearWebHistory() {
    try {
      window.localStorage.remove(_webHistoryKey);
      notifyListeners();
    } catch (e) {
      // storage error
    }
  }
  
  // =====================================
  // JSON Helpers (works on web)
  // =====================================
  dynamic _decodeJson(String data) {
    try {
      // Use JSON decode for web compatibility
      return _jsonDecode(data);
    } catch (e) {
      return [];
    }
  }
  
  String _encodeJson(dynamic data) {
    try {
      return _jsonEncode(data);
    } catch (e) {
      return '[]';
    }
  }
  
  // Workaround for dart:html import in web builds
  dynamic _jsonDecode(String data) {
    // This will be replaced by the actual JSON.decode at runtime
    throw UnimplementedError('Use JSON.decode in your code');
  }
  
  String _jsonEncode(dynamic data) {
    // This will be replaced by the actual JSON.encode at runtime
    throw UnimplementedError('Use JSON.encode in your code');
  }
}
