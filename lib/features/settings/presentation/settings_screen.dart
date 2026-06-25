import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/application/app_theme_mode_controller.dart';
import '../../../core/config/app_spacing.dart';
import '../../../core/shared/widgets/app_page.dart';
import '../../../core/shared/widgets/app_section_header.dart';
import '../../../core/shared/widgets/commander_card.dart';
import '../../../l10n/application/app_locale_controller.dart';
import '../../../l10n/l10n.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(appLocaleControllerProvider);
    final themeMode = ref.watch(appThemeModeControllerProvider);

    return AppPage(
      slivers: [
        SliverToBoxAdapter(
          child: AppSectionHeader(
            title: l10n.settingsTitle,
            subtitle: l10n.settingsSubtitle,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
        SliverToBoxAdapter(
          child: CommanderCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appearance,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(l10n.theme, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.systemTheme),
                      icon: const Icon(Icons.brightness_auto_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.lightTheme),
                      icon: const Icon(Icons.light_mode_rounded),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.darkTheme),
                      icon: const Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref
                        .read(appThemeModeControllerProvider.notifier)
                        .setThemeMode(selection.first);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<Locale>(
                  segments: [
                    ButtonSegment(
                      value: AppLocaleController.english,
                      label: Text(l10n.english),
                      icon: const Icon(Icons.language_rounded),
                    ),
                    ButtonSegment(
                      value: AppLocaleController.arabic,
                      label: Text(l10n.arabic),
                      icon: const Icon(Icons.translate_rounded),
                    ),
                  ],
                  selected: {locale},
                  onSelectionChanged: (selection) {
                    ref
                        .read(appLocaleControllerProvider.notifier)
                        .setLocale(selection.first);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
