import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:router_commander_ai/core/config/app_spacing.dart';
import 'package:router_commander_ai/core/shared/widgets/app_page.dart';
import 'package:router_commander_ai/core/shared/widgets/app_section_header.dart';
import 'package:router_commander_ai/core/shared/widgets/feature_empty_state.dart';
import 'package:router_commander_ai/features/routers/presentation/providers/routers_list_notifier.dart';
import 'package:router_commander_ai/features/routers/presentation/providers/router_session_notifier.dart';
import 'package:router_commander_ai/features/routers/presentation/widgets/add_router_modal.dart';
import 'package:router_commander_ai/l10n/l10n.dart';

class RoutersScreen extends ConsumerWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final asyncProfiles = ref.watch(routersListNotifierProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddRouterModal.show(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addRouterTitle),
      ),
      body: AppPage(
        slivers: [
          SliverToBoxAdapter(
            child: AppSectionHeader(
              title: l10n.routersTitle,
              subtitle: l10n.routersSubtitle,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          asyncProfiles.when(
            data: (profiles) {
              if (profiles.isEmpty) {
                return SliverToBoxAdapter(
                  child: FeatureEmptyState(
                    icon: Icons.router_rounded,
                    title: l10n.routersEmptyTitle,
                    message: l10n.routersEmptyMessage,
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final profile = profiles[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ListTile(
                        leading: const Icon(Icons.router_rounded),
                        title: Text(profile.name),
                        subtitle: Text(profile.endpoint.baseUri),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref.read(routersListNotifierProvider.notifier).deleteProfile(profile.id);
                              },
                            ),
                            FilledButton.tonal(
                              onPressed: () {
                                ref.read(routerSessionNotifierProvider.notifier).login(
                                  endpoint: profile.endpoint,
                                  credentials: profile.credentials,
                                );
                                // Ideally navigate to dashboard here or show snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Connecting to ${profile.name}...')),
                                );
                              },
                              child: Text(l10n.connect),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: profiles.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $err')),
            ),
          ),
          // Add padding for the FAB
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
