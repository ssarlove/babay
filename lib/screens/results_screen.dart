import 'package:flutter/material.dart';
import '../utils/theme/app_theme.dart';
import '../components/emotion_display.dart';
import '../components/suggestion_card.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final List<dynamic> suggestions;

  const ResultsScreen({super.key, required this.result, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmotionDisplay(
              emotion: result['emotion'],
              confidence: result['confidence'] ?? 0.0,
            ),
            const SizedBox(height: 24),
            Text(
              'Suggestions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...suggestions.map(
              (suggestion) => SuggestionCard(
                text: suggestion['text'] as String,
                category: suggestion['category'] as String,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Scan Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}