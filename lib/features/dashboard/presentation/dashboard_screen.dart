import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:router_commander_ai/app/theme/app_color_system.dart';
import 'package:router_commander_ai/core/config/app_spacing.dart';
import 'package:router_commander_ai/core/shared/widgets/app_page.dart';
import 'package:router_commander_ai/core/shared/widgets/app_section_header.dart';
import 'package:router_commander_ai/core/shared/widgets/commander_card.dart';
import 'package:router_commander_ai/core/shared/widgets/metric_tile.dart';
import 'package:router_commander_ai/core/shared/widgets/responsive_grid.dart';
import 'package:router_commander_ai/l10n/l10n.dart';
import 'package:router_commander_ai/features/dashboard/application/dashboard_notifier.dart';
import 'package:router_commander_ai/features/routers/presentation/providers/router_session_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatUptime(Duration? uptime) {
    if (uptime == null || uptime.inSeconds == 0) return '-';
    final hours = uptime.inHours;
    final minutes = (uptime.inMinutes % 60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final connectionState = ref.watch(routerSessionNotifierProvider);
    final dashboardAsyncValue = ref.watch(dashboardNotifierProvider);

    final dashboardState = dashboardAsyncValue.value;

    final String routerStatusValue = connectionState.whenOrNull(
      connected: (_) => dashboardState?.deviceInfo.modelName ?? l10n.connected,
      connecting: () => l10n.connecting,
      failed: (_) => l10n.connectionFailed,
    ) ?? l10n.noRouterConnected;

    final String wanIpValue = dashboardState?.wanStatus.ipAddress ?? l10n.wanIpNotAvailable;
    final String activeDevicesValue = dashboardState?.connectedDevicesCount.toString() ?? l10n.notMeasured;
    final String uptimeValue = _formatUptime(dashboardState?.deviceInfo.uptime);

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
                value: routerStatusValue,
                icon: Icons.router_rounded,
                accentColor: AppColorSystem.sky,
              ),
              MetricTile(
                label: l10n.wanIp,
                value: wanIpValue,
                icon: Icons.public_rounded,
                accentColor: AppColorSystem.mint,
              ),
              MetricTile(
                label: l10n.activeDevices,
                value: activeDevicesValue,
                icon: Icons.devices_rounded,
                accentColor: AppColorSystem.violet,
              ),
              MetricTile(
                label: l10n.uptime,
                value: uptimeValue,
                icon: Icons.timer_rounded,
                accentColor: AppColorSystem.coral,
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        if (dashboardState == null)
          SliverToBoxAdapter(
            child: CommanderCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.noRouterConnected,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.dashboardEmptyStateMessage,
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
