import 'package:flutter/material.dart';

import '../../config/app_spacing.dart';
import 'commander_card.dart';

class FeatureEmptyState extends StatelessWidget {
  const FeatureEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CommanderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Icon(icon),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
