// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter_test/flutter_test.dart';
import 'package:router_commander_ai/core/errors/app_exception.dart';
import 'package:router_commander_ai/core/protocol/protocol_logger.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_session_extractor.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';

void main() {
  final extractor =
      ZteSessionExtractor(logger: const SilentProtocolLogger());

  final endpoint = RouterEndpoint.fromHost('192.168.0.1');
  final model = RouterModel(
    brand: RouterBrand.zte,
    modelName: 'MF297D',
    hardwareVersion: null,
    firmwareVersion: null,
  );

  // ── stok cookie (VERIFIED — MF79U, MF266) ────────────────────────────────
  group('ZteSessionExtractor — stok cookie (VERIFIED)', () {
    test('extracts stok value from Set-Cookie header', () {
      const raw = 'stok=abc123def456; Path=/; HttpOnly';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
      );
      expect(session.cookieHeader, equals('stok=abc123def456'));
      expect(session.metadata['cookieName'], equals('stok'));
    });

    test('session id encodes the cookie pair', () {
      const raw = 'stok=mytoken; Path=/';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
      );
      expect(session.id, contains('stok='));
    });
  });

  // ── zsidn cookie (VERIFIED — MF297D) ─────────────────────────────────────
  group('ZteSessionExtractor — zsidn cookie (VERIFIED)', () {
    test('extracts zsidn value from Set-Cookie header', () {
      const raw = 'zsidn=xyz789uvw012; Path=/; HttpOnly';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
      );
      expect(session.cookieHeader, equals('zsidn=xyz789uvw012'));
      expect(session.metadata['cookieName'], equals('zsidn'));
    });
  });

  // ── priority when both present ────────────────────────────────────────────
  group('ZteSessionExtractor — priority', () {
    test('prefers stok over zsidn when both present', () {
      const raw = 'stok=first; zsidn=second; Path=/';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
      );
      expect(session.metadata['cookieName'], equals('stok'));
    });
  });

  // ── protocol violation: no known cookie ───────────────────────────────────
  group('ZteSessionExtractor — protocol violation', () {
    test('throws SessionException when no known cookie is found', () {
      const raw = 'PHPSESSID=unknown; Path=/';
      expect(
        () => extractor.extract(
          rawSetCookie: raw,
          endpoint: endpoint,
          model: model,
        ),
        throwsA(isA<SessionException>()),
      );
    });

    test('throws SessionException for empty header', () {
      expect(
        () => extractor.extract(
          rawSetCookie: '',
          endpoint: endpoint,
          model: model,
        ),
        throwsA(isA<SessionException>()),
      );
    });
  });

  // ── session metadata ──────────────────────────────────────────────────────
  group('ZteSessionExtractor — session metadata', () {
    test('propagates expiresAt to the session', () {
      final expiry = DateTime(2026, 6, 26, 23, 0);
      const raw = 'stok=tok; Path=/';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
        expiresAt: expiry,
      );
      expect(session.expiresAt, equals(expiry));
    });

    test('session is not expired when expiresAt is in the future', () {
      final expiry = DateTime.now().add(const Duration(hours: 1));
      const raw = 'stok=tok; Path=/';
      final session = extractor.extract(
        rawSetCookie: raw,
        endpoint: endpoint,
        model: model,
        expiresAt: expiry,
      );
      expect(session.isExpired, isFalse);
    });
  });
}
