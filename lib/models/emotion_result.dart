import 'package:hive/hive.dart';

part 'emotion_result.g.dart';

@HiveType(typeId: 1)
class EmotionResult {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String dominantEmotion;
  
  @HiveField(2)
  final Map<String, double> probabilities;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final List<String> suggestions;
  
  @HiveField(5)
  final bool userConfirmed;
  
  @HiveField(6)
  final String? imagePath;

  EmotionResult({
    String? id,
    required this.dominantEmotion,
    required this.probabilities,
    DateTime? timestamp,
    required this.suggestions,
    this.userConfirmed = false,
    this.imagePath,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  double get confidence => probabilities[dominantEmotion] ?? 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dominantEmotion': dominantEmotion,
      'probabilities': probabilities,
      'timestamp': timestamp.toIso8601String(),
      'suggestions': suggestions,
      'userConfirmed': userConfirmed,
    };
  }

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      id: json['id'],
      dominantEmotion: json['dominantEmotion'],
      probabilities: Map<String, double>.from(json['probabilities']),
      timestamp: DateTime.parse(json['timestamp']),
      suggestions: List<String>.from(json['suggestions']),
      userConfirmed: json['userConfirmed'] ?? false,
    );
  }
}