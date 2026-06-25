import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/config/app_breakpoints.dart';
import '../core/config/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/application/app_locale_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/application/app_theme_mode_controller.dart';

class RouterCommanderApp extends ConsumerWidget {
  const RouterCommanderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleControllerProvider);
    final themeMode = ref.watch(appThemeModeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child ?? const SizedBox.shrink(),
          breakpoints: AppBreakpoints.responsiveBreakpoints,
        );
      },
    );
  }
}
