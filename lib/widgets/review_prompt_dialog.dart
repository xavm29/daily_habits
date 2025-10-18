import 'package:flutter/material.dart';
import 'package:daily_habits/styles/styles.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          Text(
            l10n.enjoyingDailyHabits,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.wedLoveToHearYourFeedback,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.yourReviewHelpsUs,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Row(
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
          child: Text(l10n.noThanks, style: const TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: onLater,
          child: Text(l10n.maybeLater),
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
          child: Text(l10n.rateNow),
        ),
      ],
    );
  }
}
