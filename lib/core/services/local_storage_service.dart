import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return HiveLocalStorageService();
});

abstract interface class LocalStorageService {
  Future<Box<dynamic>> openBox(String name);
}

class HiveLocalStorageService implements LocalStorageService {
  @override
  Future<Box<dynamic>> openBox(String name) {
    return Hive.openBox<dynamic>(name);
  }
}
