import 'package:flutter/material.dart';

import '../../config/app_spacing.dart';
import 'commander_card.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CommanderCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(label, style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
