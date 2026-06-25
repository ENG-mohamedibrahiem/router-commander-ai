import 'package:flutter/material.dart';

import '../../../core/config/app_spacing.dart';
import '../../../core/shared/widgets/app_page.dart';
import '../../../core/shared/widgets/app_section_header.dart';
import '../../../core/shared/widgets/feature_empty_state.dart';
import '../../../l10n/l10n.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppPage(
      slivers: [
        SliverToBoxAdapter(
          child: AppSectionHeader(
            title: l10n.aiAssistantTitle,
            subtitle: l10n.aiAssistantSubtitle,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: FeatureEmptyState(
            icon: Icons.auto_awesome_rounded,
            title: l10n.aiEmptyTitle,
            message: l10n.aiEmptyMessage,
          ),
        ),
      ],
    );
  }
}
