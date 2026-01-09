import 'package:flutter/foundation.dart';

class SuggestionEngine {
  // Base suggestions for each emotion
  final Map<String, List<dynamic>> _emotionSuggestions = {
    'crying': [
      {
        'text': 'Check if diaper needs changing',
        'category': 'basic_care',
        'priority': 1,
      },
      {
        'text': 'Offer a feeding - baby may be hungry',
        'category': 'feeding',
        'priority': 1,
      },
      {
        'text': 'Try burping - baby might have gas',
        'category': 'comfort',
        'priority': 2,
      },
      {
        'text': 'Check temperature - baby might be too hot or cold',
        'category': 'basic_care',
        'priority': 2,
      },
      {
        'text': 'Try swaddling for comfort',
        'category': 'comfort',
        'priority': 3,
      },
      {
        'text': 'Rock gently and soothe with movement',
        'category': 'comfort',
        'priority': 3,
      },
      {
        'text': 'Check for hair wrapped around fingers or toes',
        'category': 'basic_care',
        'priority': 1,
      },
      {
        'text': 'Offer a pacifier if you use one',
        'category': 'comfort',
        'priority': 4,
      },
    ],
    'happy': [
      {
        'text': 'Engage in tummy time',
        'category': 'development',
        'priority': 1,
      },
      {
        'text': 'Play peek-a-boo for social bonding',
        'category': 'play',
        'priority': 1,
      },
      {
        'text': 'Show high-contrast cards for visual development',
        'category': 'development',
        'priority': 2,
      },
      {
        'text': 'Talk and sing to baby - they love your voice!',
        'category': 'bonding',
        'priority': 1,
      },
      {
        'text': 'Encourage reaching and grasping with toys',
        'category': 'development',
        'priority': 2,
      },
      {
        'text': 'Dance and move with baby for vestibular development',
        'category': 'play',
        'priority': 3,
      },
    ],
    'laughing': [
      {
        'text': 'Play gentle tickle games',
        'category': 'play',
        'priority': 1,
      },
      {
        'text': 'Make silly faces and funny sounds',
        'category': 'play',
        'priority': 1,
      },
      {
        'text': 'Introduce safe rattles and toys',
        'category': 'play',
        'priority': 2,
      },
      {
        'text': 'Dance and move rhythmically with baby',
        'category': 'play',
        'priority': 2,
      },
      {
        'text': 'Play "this little piggy" on their toes',
        'category': 'play',
        'priority': 3,
      },
    ],
    'tired': [
      {
        'text': 'Begin wind-down routine now',
        'category': 'sleep',
        'priority': 1,
      },
      {
        'text': 'Dim lights and reduce stimulation',
        'category': 'sleep',
        'priority': 1,
      },
      {
        'text': 'Offer pacifier if you use one',
        'category': 'comfort',
        'priority': 2,
      },
      {
        'text': 'Swaddle for sleep if age-appropriate',
        'category': 'sleep',
        'priority': 2,
      },
      {
        'text': 'Play soft white noise or shushing sounds',
        'category': 'sleep',
        'priority': 3,
      },
      {
        'text': 'Start a consistent bedtime routine',
        'category': 'sleep',
        'priority': 3,
      },
    ],
    'neutral': [
      {
        'text': 'Talk and sing to baby',
        'category': 'bonding',
        'priority': 1,
      },
      {
        'text': 'Engage with age-appropriate toys',
        'category': 'play',
        'priority': 1,
      },
      {
        'text': 'Take for a walk outside for fresh air',
        'category': 'stimulation',
        'priority': 2,
      },
      {
        'text': 'Read a board book together',
        'category': 'development',
        'priority': 2,
      },
      {
        'text': 'Practice tummy time',
        'category': 'development',
        'priority': 3,
      },
    ],
  };

  // Time-based context modifiers
  final Map<String, List<String>> _timeContextModifiers = {
    'night': [
      'Night time: Keep interactions quiet and minimal',
      'Use a soft voice and gentle movements',
    ],
    'early_morning': [
      'Early morning: Baby may still be sleepy',
      'Keep stimulation low until fully awake',
    ],
    'witching_hour': [
      'Witching hour detected (5-8 PM): Baby may be extra fussy',
      'Try going outside for a change of scenery',
      'This is normal - hang in there!',
    ],
    'feeding_time': [
      'Consider if it might be feeding time soon',
      'Watch for hunger cues like rooting',
    ],
  };

  List<Map<String, dynamic>> getSuggestions(
    String emotion, {
    DateTime? timestamp,
    Map<String, dynamic>? context,
  }) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Get base suggestions for emotion
    final baseSuggestions = _emotionSuggestions[emotion.toLowerCase()] ?? [];
    
    // Sort by priority and add to results
    final sortedSuggestions = [...baseSuggestions]..sort((a, b) {
      final priorityA = a['priority'] ?? 5;
      final priorityB = b['priority'] ?? 5;
      return priorityA.compareTo(priorityB);
    });
    
    suggestions.addAll(sortedSuggestions.take(5));
    
    // Add time-based context
    if (timestamp != null) {
      final timeContext = _getTimeContext(timestamp);
      final contextModifiers = _timeContextModifiers[timeContext] ?? [];
      
      for (final modifier in contextModifiers) {
        suggestions.insert(0, {
          'text': modifier,
          'category': 'context',
          'priority': 0,
        });
      }
    }

    return suggestions;
  }

  String _getTimeContext(DateTime timestamp) {
    final hour = timestamp.hour;
    
    if (hour >= 0 && hour < 6) {
      return 'night';
    } else if (hour >= 5 && hour < 21) {
      return 'witching_hour';
    } else if (hour >= 17 && hour < 21) {
      return 'witching_hour';
    }
    
    return 'normal';
  }

  List<String> getQuickTips(String emotion) {
    final suggestions = getSuggestions(emotion);
    return suggestions.take(3).map((s) => s['text'] as String).toList();
  }
}