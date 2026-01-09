import 'package:hive/hive.dart';

part 'suggestion.g.dart';

@HiveType(typeId: 2)
class Suggestion {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String emotion;
  
  @HiveField(2)
  final String text;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final int priority;

  Suggestion({
    String? id,
    required this.emotion,
    required this.text,
    this.category = 'general',
    this.priority = 0,
  }) : id = id ?? '${emotion}_${text.hashCode}';

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      emotion: json['emotion'],
      text: json['text'],
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 0,
    );
  }
}