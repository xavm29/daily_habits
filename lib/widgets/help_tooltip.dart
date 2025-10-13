import 'package:flutter/material.dart';
import '../styles/styles.dart';

class HelpTooltip extends StatelessWidget {
  final String message;
  final IconData icon;

  const HelpTooltip({
    Key? key,
    required this.message,
    this.icon = Icons.help_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: AppColors.primarys,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      padding: const EdgeInsets.all(12),
      preferBelow: false,
      child: Icon(
        icon,
        size: 20,
        color: AppColors.primarys.withOpacity(0.7),
      ),
    );
  }
}

// Widget para mostrar tips flotantes
class HelpCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onDismiss;

  const HelpCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.primarys.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primarys.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarys.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primarys, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
