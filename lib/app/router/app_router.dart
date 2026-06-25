import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/network_tools/presentation/network_tools_screen.dart';
import '../../features/routers/presentation/routers_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import 'app_route.dart';
import 'router_commander_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.dashboard.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RouterCommanderShell(navigationShell: navigationShell);
        },
        branches: [
          _branch(AppRoute.dashboard, const DashboardScreen()),
          _branch(AppRoute.routers, const RoutersScreen()),
          _branch(AppRoute.tools, const NetworkToolsScreen()),
          _branch(AppRoute.aiAssistant, const AiAssistantScreen()),
          _branch(AppRoute.settings, const SettingsScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(AppRoute route, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: route.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: screen,
        ),
      ),
    ],
  );
}
