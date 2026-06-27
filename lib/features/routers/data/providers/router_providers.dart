import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:router_commander_ai/core/services/local_storage_service.dart';
import 'package:router_commander_ai/features/routers/data/factories/router_adapter_factory_impl.dart';
import 'package:router_commander_ai/features/routers/data/discovery/network_scanner_service.dart';
import 'package:router_commander_ai/features/routers/data/repositories/hive_router_profile_repository.dart';
import 'package:router_commander_ai/features/routers/data/repositories/router_repository_impl.dart';
import 'package:router_commander_ai/features/routers/data/services/hive_session_storage_service.dart';
import 'package:router_commander_ai/features/routers/domain/factories/router_adapter_factory.dart';
import 'package:router_commander_ai/features/routers/domain/repositories/router_profile_repository.dart';
import 'package:router_commander_ai/features/routers/domain/repositories/router_repository.dart';
import 'package:router_commander_ai/features/routers/domain/services/session_storage_contract.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:router_commander_ai/core/network/network_client_provider.dart';
import 'package:router_commander_ai/core/protocol/protocol_logger.dart';

// ---------------------------------------------------------------------------
// Infrastructure dependencies
// ---------------------------------------------------------------------------

final networkScannerServiceProvider = Provider<NetworkScannerService>((ref) {
  return NetworkScannerService();
});

/// Provides the [Dio] instance via [networkClientProvider].
/// Declared here as a typed alias for clarity.
final routerDioProvider = Provider<Dio>((ref) {
  return ref.watch(networkClientProvider);
});

/// Provides the shared [ProtocolLogger].
final protocolLoggerProvider = Provider<ProtocolLogger>((ref) {
  return const ProtocolLogger();
});

// ---------------------------------------------------------------------------
// Session storage
// ---------------------------------------------------------------------------

/// Provides the Hive box for session storage.
///
/// The box **must** be opened during app bootstrap before this provider
/// is first read. See [AppBootstrapService.initialize].
final sessionBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>(
      HiveSessionStorageService.kSessionBoxName);
});

/// Provides the [SessionStorageContract] implementation.
final sessionStorageProvider =
    Provider<SessionStorageContract>((ref) {
  return HiveSessionStorageService(
      box: ref.watch(sessionBoxProvider));
});

// ---------------------------------------------------------------------------
// Adapter factory
// ---------------------------------------------------------------------------

/// Provides the [RouterAdapterFactory] implementation.
final routerAdapterFactoryProvider =
    Provider<RouterAdapterFactory>((ref) {
  return RouterAdapterFactoryImpl(
    dio: ref.watch(routerDioProvider),
    logger: ref.watch(protocolLoggerProvider),
  );
});

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

/// Provides the [RouterRepository] implementation.
///
/// This is the **single entry point** for the presentation layer to
/// interact with routers. All feature notifiers depend on this provider.
final routerRepositoryProvider = Provider<RouterRepository>((ref) {
  return RouterRepositoryImpl(
    factory: ref.watch(routerAdapterFactoryProvider),
    sessionStorage: ref.watch(sessionStorageProvider),
  );
});

// ---------------------------------------------------------------------------
// Profile Repository
// ---------------------------------------------------------------------------

final routerProfileRepositoryProvider = Provider<RouterProfileRepository>((ref) {
  return HiveRouterProfileRepository(LocalStorageService.instance);
});
