import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:router_commander_ai/app/router/app_route.dart';

import 'package:router_commander_ai/app/theme/app_color_system.dart';
import 'package:router_commander_ai/core/config/app_spacing.dart';
import 'package:router_commander_ai/core/shared/widgets/app_page.dart';
import 'package:router_commander_ai/core/shared/widgets/app_section_header.dart';
import 'package:router_commander_ai/core/shared/widgets/metric_tile.dart';
import 'package:router_commander_ai/core/shared/widgets/responsive_grid.dart';
import 'package:router_commander_ai/l10n/l10n.dart';

class NetworkToolsScreen extends StatelessWidget {
  const NetworkToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppPage(
      slivers: [
        SliverToBoxAdapter(
          child: AppSectionHeader(
            title: l10n.toolsTitle,
            subtitle: l10n.toolsSubtitle,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: ResponsiveGrid(
            children: [
              MetricTile(
                label: l10n.wifi,
                value: l10n.toolReady,
                icon: Icons.wifi_rounded,
                accentColor: AppColorSystem.mint,
                onTap: () => context.go(AppRoute.wifi.path),
              ),
              MetricTile(
                label: l10n.connectedDevices,
                value: l10n.toolReady,
                icon: Icons.devices_other_rounded,
                accentColor: AppColorSystem.sky,
                onTap: () => context.go(AppRoute.connectedDevices.path),
              ),
              MetricTile(
                label: l10n.dsl,
                value: l10n.toolReady,
                icon: Icons.settings_input_component_rounded,
                accentColor: AppColorSystem.amber,
                onTap: () => context.go(AppRoute.dsl.path),
              ),
              MetricTile(
                label: l10n.speedTest,
                value: l10n.toolReady,
                icon: Icons.speed_rounded,
                accentColor: AppColorSystem.coral,
              ),
              MetricTile(
                label: l10n.security,
                value: l10n.toolReady,
                icon: Icons.shield_rounded,
                accentColor: AppColorSystem.violet,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
