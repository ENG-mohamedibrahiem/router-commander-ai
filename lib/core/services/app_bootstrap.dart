import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'local_storage_service.dart';
import 'package:router_commander_ai/features/routers/data/services/hive_session_storage_service.dart';

/// Bootstraps all services required before `runApp`.
///
/// Call order:
///   1. Flutter bindings
///   2. Hive initialisation
///   3. Open all Hive boxes (sessions, settings, credentials, routers)
///   4. LocalStorageService singleton init
class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Open the typed session box used by HiveSessionStorageService.
    await Hive.openBox<String>(HiveSessionStorageService.kSessionBoxName);

    // Open all generic boxes used by LocalStorageService.
    await LocalStorageService.instance.init();
  }
}
