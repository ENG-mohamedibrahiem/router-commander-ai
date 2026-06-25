import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppBootstrap {
  const AppBootstrap._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
  }
}
