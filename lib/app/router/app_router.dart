import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:router_commander_ai/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:router_commander_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:router_commander_ai/features/network_tools/presentation/network_tools_screen.dart';
import 'package:router_commander_ai/features/network_tools/presentation/screens/connected_devices_screen.dart';
import 'package:router_commander_ai/features/network_tools/presentation/screens/dsl_screen.dart';
import 'package:router_commander_ai/features/network_tools/presentation/screens/wifi_screen.dart';
import 'package:router_commander_ai/features/routers/presentation/routers_screen.dart';
import 'package:router_commander_ai/features/settings/presentation/settings_screen.dart';
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
          _branch(
            AppRoute.tools,
            const NetworkToolsScreen(),
            subRoutes: [
              GoRoute(
                path: AppRoute.connectedDevices.path,
                builder: (context, state) => const ConnectedDevicesScreen(),
              ),
              GoRoute(
                path: AppRoute.wifi.path,
                builder: (context, state) => const WifiScreen(),
              ),
              GoRoute(
                path: AppRoute.dsl.path,
                builder: (context, state) => const DslScreen(),
              ),
            ],
          ),
          _branch(AppRoute.aiAssistant, const AiAssistantScreen()),
          _branch(AppRoute.settings, const SettingsScreen()),
        ],
      ),
    ],
  );
});

StatefulShellBranch _branch(
  AppRoute route,
  Widget screen, {
  List<RouteBase> subRoutes = const [],
}) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: route.path,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: screen,
        ),
        routes: subRoutes,
      ),
    ],
  );
}
