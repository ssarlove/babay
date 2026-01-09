import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  final String text;
  final String category;

  const SuggestionCard({
    super.key,
    required this.text,
    this.category = 'general',
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                categoryIcon,
                size: 20,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'feeding':
        return Colors.orange;
      case 'comfort':
        return Colors.pink;
      case 'sleep':
        return Colors.purple;
      case 'development':
        return Colors.blue;
      case 'play':
        return Colors.green;
      case 'bonding':
        return Colors.teal;
      case 'basic_care':
        return Colors.blueGrey;
      case 'context':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'feeding':
        return Icons.restaurant;
      case 'comfort':
        return Icons.favorite;
      case 'sleep':
        return Icons.bedtime;
      case 'development':
        return Icons.developer_board;
      case 'play':
        return Icons.sports_baseball;
      case 'bonding':
        return Icons.people;
      case 'basic_care':
        return Icons.child_care;
      case 'context':
        return Icons.lightbulb;
      default:
        return Icons.check;
    }
  }
}