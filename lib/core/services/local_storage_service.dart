import 'package:hive_flutter/hive_flutter.dart';
import 'package:router_commander_ai/core/config/app_constants.dart';

/// Typed wrapper around Hive boxes with TTL support (Option C).
///
/// TTL is enforced at read time: expired entries are deleted and null
/// is returned, identical to a missing key.
class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  late Box<dynamic> _sessionBox;
  late Box<dynamic> _settingsBox;
  late Box<dynamic> _credentialsBox;

  /// Must be called once during app bootstrap (after Hive.initFlutter).
  Future<void> init() async {
    _sessionBox = await Hive.openBox<dynamic>(AppConstants.sessionBoxName);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBoxName);
    _credentialsBox =
        await Hive.openBox<dynamic>(AppConstants.credentialsBoxName);
  }

  // ── Session (with TTL) ─────────────────────────────────────────────────────

  /// Persist [value] under [key] with a TTL of [AppConstants.sessionTtlMinutes].
  Future<void> saveSession(String key, Map<String, dynamic> value) async {
    final entry = {
      'data': value,
      'savedAt': DateTime.now().toIso8601String(),
    };
    await _sessionBox.put(key, entry);
  }

  /// Returns the stored session for [key], or null if missing / expired.
  Map<String, dynamic>? readSession(String key) {
    final raw = _sessionBox.get(key) as Map?;
    if (raw == null) return null;

    final savedAt = DateTime.tryParse(raw['savedAt'] as String? ?? '');
    if (savedAt == null) return null;

    final age = DateTime.now().difference(savedAt);
    if (age.inMinutes >= AppConstants.sessionTtlMinutes) {
      _sessionBox.delete(key);
      return null;
    }

    return Map<String, dynamic>.from(raw['data'] as Map);
  }

  Future<void> deleteSession(String key) => _sessionBox.delete(key);

  Future<void> clearAllSessions() => _sessionBox.clear();

  // ── Settings ───────────────────────────────────────────────────────────────

  Future<void> saveSetting<T>(String key, T value) =>
      _settingsBox.put(key, value);

  T? readSetting<T>(String key) => _settingsBox.get(key) as T?;

  T readSettingOrDefault<T>(String key, T defaultValue) =>
      _settingsBox.get(key, defaultValue: defaultValue) as T;

  Future<void> deleteSetting(String key) => _settingsBox.delete(key);

  // ── Credentials ────────────────────────────────────────────────────────────

  Future<void> saveCredentials(
    String routerId,
    Map<String, dynamic> credentials,
  ) =>
      _credentialsBox.put(routerId, credentials);

  Map<String, dynamic>? readCredentials(String routerId) {
    final raw = _credentialsBox.get(routerId) as Map?;
    return raw == null ? null : Map<String, dynamic>.from(raw);
  }

  Future<void> deleteCredentials(String routerId) =>
      _credentialsBox.delete(routerId);

  Future<void> clearAllCredentials() => _credentialsBox.clear();
}
