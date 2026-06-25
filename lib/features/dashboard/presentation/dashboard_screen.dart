import 'package:flutter/material.dart';

import '../../../app/theme/app_color_system.dart';
import '../../../core/config/app_spacing.dart';
import '../../../core/shared/widgets/app_page.dart';
import '../../../core/shared/widgets/app_section_header.dart';
import '../../../core/shared/widgets/commander_card.dart';
import '../../../core/shared/widgets/metric_tile.dart';
import '../../../core/shared/widgets/responsive_grid.dart';
import '../../../l10n/l10n.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppPage(
      slivers: [
        SliverToBoxAdapter(
          child: AppSectionHeader(
            title: l10n.dashboardTitle,
            subtitle: l10n.dashboardSubtitle,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: CommanderCard(
            gradient: AppColorSystem.commandGradient,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.router_rounded,
                  color: Colors.white.withValues(alpha: 0.92),
                  size: 34,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.commandCenterTitle,
                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.commandCenterSubtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: ResponsiveGrid(
            children: [
              MetricTile(
                label: l10n.routerStatus,
                value: l10n.noRouterConnected,
                icon: Icons.router_rounded,
                accentColor: AppColorSystem.sky,
              ),
              MetricTile(
                label: l10n.wifiHealth,
                value: l10n.awaitingNetworkScan,
                icon: Icons.wifi_rounded,
                accentColor: AppColorSystem.mint,
              ),
              MetricTile(
                label: l10n.security,
                value: l10n.baselineReady,
                icon: Icons.shield_rounded,
                accentColor: AppColorSystem.violet,
              ),
              MetricTile(
                label: l10n.speedTest,
                value: l10n.notMeasured,
                icon: Icons.speed_rounded,
                accentColor: AppColorSystem.coral,
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: CommanderCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.foundationReadyTitle,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.foundationReadyMessage,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
