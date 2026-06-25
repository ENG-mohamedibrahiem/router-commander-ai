import 'package:flutter/material.dart';

import '../../../core/config/app_spacing.dart';
import '../../../core/shared/widgets/app_page.dart';
import '../../../core/shared/widgets/app_section_header.dart';
import '../../../core/shared/widgets/feature_empty_state.dart';
import '../../../l10n/l10n.dart';

class RoutersScreen extends StatelessWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppPage(
      slivers: [
        SliverToBoxAdapter(
          child: AppSectionHeader(
            title: l10n.routersTitle,
            subtitle: l10n.routersSubtitle,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: FeatureEmptyState(
            icon: Icons.router_rounded,
            title: l10n.routersEmptyTitle,
            message: l10n.routersEmptyMessage,
          ),
        ),
      ],
    );
  }
}
