import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:router_commander_ai/features/routers/domain/entities/router_brand.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_session.dart';
import 'package:router_commander_ai/features/routers/domain/services/session_storage_contract.dart';

/// Hive-backed [SessionStorageContract] implementation (Option C — TTL).
///
/// Storage format: JSON map keyed by `RouterEndpoint.cacheKey`.
/// Expired sessions are silently discarded on [load].
///
/// Box name: [kSessionBoxName]. Must be opened during app bootstrap.
final class HiveSessionStorageService implements SessionStorageContract {
  const HiveSessionStorageService({required this._box});

  final Box<String> _box;

  static const String kSessionBoxName = 'router_sessions';

  // -------------------------------------------------------------------------
  // Contract
  // -------------------------------------------------------------------------

  @override
  Future<void> save(
      RouterEndpoint endpoint, RouterSession session) async {
    final key = _key(endpoint);
    final encoded = jsonEncode(_sessionToMap(session));
    await _box.put(key, encoded);
  }

  @override
  Future<RouterSession?> load(RouterEndpoint endpoint) async {
    final key = _key(endpoint);
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final session = _sessionFromMap(map, endpoint);
      if (session.isExpired) {
        await invalidate(endpoint);
        return null;
      }
      return session;
    } catch (_) {
      // Corrupted entry — purge silently.
      await invalidate(endpoint);
      return null;
    }
  }

  @override
  Future<void> invalidate(RouterEndpoint endpoint) async {
    await _box.delete(_key(endpoint));
  }

  @override
  Future<void> invalidateAll() async {
    await _box.clear();
  }

  // -------------------------------------------------------------------------
  // Serialisation helpers
  // -------------------------------------------------------------------------

  String _key(RouterEndpoint endpoint) => endpoint.cacheKey;

  Map<String, dynamic> _sessionToMap(RouterSession s) => {
        'id': s.id,
        'createdAt': s.createdAt.toIso8601String(),
        'expiresAt': s.expiresAt?.toIso8601String(),
        'authToken': s.authToken,
        'cookieHeader': s.cookieHeader,
        'brand': s.model.brand.name,
        'modelName': s.model.modelName,
        'hardwareVersion': s.model.hardwareVersion,
        'firmwareVersion': s.model.firmwareVersion,
        'metadata': s.metadata,
      };

  RouterSession _sessionFromMap(
      Map<String, dynamic> m, RouterEndpoint endpoint) {
    final brand = RouterBrand.fromString(m['brand'] as String? ?? '');
    final model = RouterModel(
      brand: brand,
      modelName: m['modelName'] as String? ?? '',
      hardwareVersion: m['hardwareVersion'] as String?,
      firmwareVersion: m['firmwareVersion'] as String?,
    );
    return RouterSession(
      id: m['id'] as String,
      endpoint: endpoint,
      model: model,
      createdAt: DateTime.parse(m['createdAt'] as String),
      expiresAt: m['expiresAt'] != null
          ? DateTime.parse(m['expiresAt'] as String)
          : null,
      authToken: m['authToken'] as String?,
      cookieHeader: m['cookieHeader'] as String?,
      metadata: (m['metadata'] as Map<String, dynamic>? ?? {})
          .cast<String, String>(),
    );
  }
}
