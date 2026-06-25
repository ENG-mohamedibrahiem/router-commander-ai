import 'package:flutter/material.dart';

import '../../../app/theme/app_color_system.dart';
import '../../../core/config/app_spacing.dart';
import '../../../core/shared/widgets/app_page.dart';
import '../../../core/shared/widgets/app_section_header.dart';
import '../../../core/shared/widgets/metric_tile.dart';
import '../../../core/shared/widgets/responsive_grid.dart';
import '../../../l10n/l10n.dart';

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
              ),
              MetricTile(
                label: l10n.connectedDevices,
                value: l10n.toolReady,
                icon: Icons.devices_other_rounded,
                accentColor: AppColorSystem.sky,
              ),
              MetricTile(
                label: l10n.dsl,
                value: l10n.toolReady,
                icon: Icons.settings_input_component_rounded,
                accentColor: AppColorSystem.amber,
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
