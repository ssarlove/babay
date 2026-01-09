import 'package:flutter/material.dart';
import '../utils/theme/app_theme.dart';

class EmotionDisplay extends StatelessWidget {
  final String emotion;
  final double confidence;

  const EmotionDisplay({
    super.key,
    required this.emotion,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final emotionColor = AppTheme.getEmotionColor(emotion);
    final emotionIcon = AppTheme.getEmotionIcon(emotion);
    final displayEmotion = _getDisplayEmotion(emotion);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: emotionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emotionColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: emotionColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              emotionIcon,
              size: 48,
              color: emotionColor,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayEmotion,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: emotionColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getEmotionDescription(emotion),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: confidence / 100,
                    minHeight: 8,
                    backgroundColor: emotionColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(emotionColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(confidence).toStringAsFixed(0)}% confidence',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'crying':
        return 'Baby Needs Attention';
      case 'happy':
        return 'Baby is Happy';
      case 'laughing':
        return 'Baby is Laughing';
      case 'tired':
        return 'Baby is Tired';
      case 'neutral':
        return 'Baby is Calm';
      default:
        return emotion;
    }
  }

  String _getEmotionDescription(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'crying':
        return 'Your baby may need comfort, feeding, or has a specific need';
      case 'happy':
        return 'Great! Your baby is content and in a good mood';
      case 'laughing':
        return 'Wonderful! Your baby is joyful and playful';
      case 'tired':
        return 'Your baby might be ready for a nap soon';
      case 'neutral':
        return 'Your baby is calm and observing';
      default:
        return '';
    }
  }
}