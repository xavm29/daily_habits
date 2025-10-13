import 'package:flutter/material.dart';
import 'package:daily_habits/styles/styles.dart';

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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: const [
          Icon(Icons.cloud_upload, color: AppColors.primarys, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Save Your Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You\'ve been doing great! 🎉',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Register now to:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildBenefit(Icons.cloud_done, 'Sync your data across devices'),
          _buildBenefit(Icons.security, 'Never lose your progress'),
          _buildBenefit(Icons.people, 'Connect with friends'),
          _buildBenefit(Icons.emoji_events, 'Join challenges'),
          _buildBenefit(Icons.backup, 'Backup your habits'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onLater,
          child: const Text('Maybe Later'),
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
          child: const Text('Register Now'),
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
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
