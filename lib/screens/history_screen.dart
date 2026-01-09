import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/emotion_result.dart';
import '../utils/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);
    final history = storageService.getHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood History'),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearConfirmation(context, storageService),
            ),
        ],
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(history, storageService),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning your baby\'s emotions\nto build a history',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<EmotionResult> history, StorageService storageService) {
    // Group by date
    final grouped = <String, List<EmotionResult>>{};
    
    for (final item in history) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        final formattedDate = _formatDate(date);
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formattedDate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((item) => _buildHistoryCard(item, storageService)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHistoryCard(EmotionResult item, StorageService storageService) {
    final emotionColor = AppTheme.getEmotionColor(item.dominantEmotion);
    final emotionIcon = AppTheme.getEmotionIcon(item.dominantEmotion);
    final time = DateFormat('h:mm a').format(item.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: emotionColor.withOpacity(0.2),
          child: Icon(emotionIcon, color: emotionColor),
        ),
        title: Text(
          item.dominantEmotion.toUpperCase(),
          style: TextStyle(
            color: emotionColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$time • ${(item.confidence * 100).toStringAsFixed(0)}% confidence',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (storageService.showConfidence)
                  _buildConfidenceBar(item.probabilities),
                const SizedBox(height: 12),
                const Text(
                  'Suggestions given:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...item.suggestions.map((suggestion) => ListTile(
                  leading: const Icon(Icons.lightbulb_outline, size: 20),
                  title: Text(suggestion),
                  dense: true,
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Was this accurate?'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_outlined, size: 18),
                      label: const Text('Yes'),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_down_outlined, size: 18),
                      label: const Text('No'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(Map<String, double> probabilities) {
    final sorted = probabilities.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topEmotions = sorted.take(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topEmotions.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: entry.value,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(entry.value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(today)) {
      return 'Today';
    } else if (DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  void _showClearConfirmation(BuildContext context, StorageService storageService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all saved mood entries.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await storageService.clearHistory();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}