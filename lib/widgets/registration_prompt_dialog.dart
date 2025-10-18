import 'package:flutter/material.dart';
import 'package:daily_habits/styles/styles.dart';
import '../l10n/app_localizations.dart';

class RegistrationPromptDialog extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLater;

  const RegistrationPromptDialog({
    Key? key,
    required this.onRegister,
    required this.onLater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          const Icon(Icons.cloud_upload, color: AppColors.primarys, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.saveYourProgress,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.youveBeenDoingGreat,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.registerNowTo,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildBenefit(context, Icons.cloud_done, l10n.syncYourDataAcrossDevices),
          _buildBenefit(context, Icons.security, l10n.neverLoseYourProgress),
          _buildBenefit(context, Icons.people, l10n.connectWithFriends),
          _buildBenefit(context, Icons.emoji_events, l10n.joinChallengesText),
          _buildBenefit(context, Icons.backup, l10n.backupYourHabits),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onLater,
          child: Text(l10n.maybeLater),
        ),
        ElevatedButton(
          onPressed: onRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarys,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(l10n.registerNow),
        ),
      ],
    );
  }

  Widget _buildBenefit(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primarys),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
