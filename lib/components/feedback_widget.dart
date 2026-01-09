import 'package:flutter/material.dart';

class FeedbackWidget extends StatelessWidget {
  final VoidCallback onConfirmed;
  final VoidCallback onRejected;

  const FeedbackWidget({
    super.key,
    required this.onConfirmed,
    required this.onRejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Was this accurate?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(
            Icons.thumb_up_outlined,
            size: 24,
          ),
          onPressed: onConfirmed,
        ),
        IconButton(
          icon: const Icon(
            Icons.thumb_down_outlined,
            size: 24,
          ),
          onPressed: onRejected,
        ),
      ],
    );
  }
}