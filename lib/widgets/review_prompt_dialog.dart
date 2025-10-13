import 'package:flutter/material.dart';
import 'package:daily_habits/styles/styles.dart';

class ReviewPromptDialog extends StatelessWidget {
  final VoidCallback onReviewNow;
  final VoidCallback onLater;
  final VoidCallback onNoThanks;

  const ReviewPromptDialog({
    Key? key,
    required this.onReviewNow,
    required this.onLater,
    required this.onNoThanks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: const [
          Icon(Icons.star, color: Colors.amber, size: 48),
          SizedBox(height: 12),
          Text(
            'Enjoying Daily Habits?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'We\'d love to hear your feedback!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Your review helps us improve and reach more people.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 28),
              Icon(Icons.star, color: Colors.amber, size: 28),
              Icon(Icons.star, color: Colors.amber, size: 28),
              Icon(Icons.star, color: Colors.amber, size: 28),
              Icon(Icons.star, color: Colors.amber, size: 28),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onNoThanks,
          child: const Text('No Thanks', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: onLater,
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: onReviewNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarys,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Rate Now'),
        ),
      ],
    );
  }
}
