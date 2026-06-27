import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_brand.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';

/// Persists [RouterSession] to Hive with a 30-minute TTL.
///
/// Option C (agreed) — Hive storage with TTL.
/// Expired sessions are never returned; they are purged on read.
final class SessionCacheService {
  static const String _boxName = 'session_cache';
  static const String _key = 'active_session';

  Future<void> save(RouterSession session) async {
    final box = await Hive.openBox<String>(_boxName);
    final payload = jsonEncode(_toMap(session));
    await box.put(_key, payload);
  }

  Future<RouterSession?> load() async {
    final box = await Hive.openBox<String>(_boxName);
    final raw = box.get(_key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final session = _fromMap(map);
      if (session.isExpired) {
        await box.delete(_key);
        return null;
      }
      return session;
    } catch (_) {
      await box.delete(_key);
      return null;
    }
  }

  Future<void> clear() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.delete(_key);
  }

  // ---------------------------------------------------------------------------
  // Serialisation helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _toMap(RouterSession s) => {
        'id': s.id,
        'host': s.endpoint.host,
        'port': s.endpoint.port,
        'useHttps': s.endpoint.useHttps,
        'brand': s.model.brand.name,
        'modelName': s.model.modelName,
        'hardwareVersion': s.model.hardwareVersion,
        'firmwareVersion': s.model.firmwareVersion,
        'createdAt': s.createdAt.toIso8601String(),
        'expiresAt': s.expiresAt?.toIso8601String(),
        'authToken': s.authToken,
        'cookieHeader': s.cookieHeader,
        'metadata': s.metadata,
      };

  RouterSession _fromMap(Map<String, dynamic> m) => RouterSession(
        id: m['id'] as String,
        endpoint: RouterEndpoint(
          host: m['host'] as String,
          port: m['port'] as int,
          useHttps: m['useHttps'] as bool? ?? false,
        ),
        model: RouterModel(
          brand: RouterBrand.fromString(m['brand'] as String? ?? 'unknown'),
          modelName: m['modelName'] as String? ?? '',
          hardwareVersion: m['hardwareVersion'] as String?,
          firmwareVersion: m['firmwareVersion'] as String?,
        ),
        createdAt: DateTime.parse(m['createdAt'] as String),
        expiresAt: m['expiresAt'] != null
            ? DateTime.parse(m['expiresAt'] as String)
            : null,
        authToken: m['authToken'] as String?,
        cookieHeader: m['cookieHeader'] as String?,
        metadata: Map<String, String>.from(
            m['metadata'] as Map? ?? {}),
      );
}
