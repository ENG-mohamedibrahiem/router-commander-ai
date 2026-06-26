// ignore_for_file: lines_longer_than_80_chars
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_commander_ai/core/errors/failure.dart';
import 'package:router_commander_ai/core/protocol/protocol_logger.dart';
import 'package:router_commander_ai/core/utils/result.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_authentication_strategy.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_password_hasher.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_session_extractor.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';

// ---------------------------------------------------------------------------
// Fake HTTP client for deterministic fixture-based testing
// ---------------------------------------------------------------------------

final class _FakeZteHttpClient implements ZteHttpClient {
  _FakeZteHttpClient({
    required this.probeResponse,
    required this.loginBodyResponse,
    this.loginSetCookie,
  });

  final Map<String, dynamic> probeResponse;
  final Map<String, dynamic> loginBodyResponse;
  final String? loginSetCookie;

  @override
  Future<Map<String, dynamic>> get(
    RouterEndpoint endpoint,
    String path, {
    required Map<String, String> queryParams,
    Map<String, String>? headers,
  }) async =>
      probeResponse;

  @override
  Future<ZtePostResult> post(
    RouterEndpoint endpoint,
    String path, {
    required String body,
    required Map<String, String> headers,
  }) async =>
      ZtePostResult(
        body: loginBodyResponse,
        setCookieHeader: loginSetCookie,
      );
}

Map<String, dynamic> _j(String json) =>
    jsonDecode(json) as Map<String, dynamic>;

// Fixture strings inlined — tests are self-contained, require no file I/O.
const _probeChained = '{"WEB_ATTR_IF_SUPPORT_SHA256": "2", "LD": "A1B2C3D4E5F60718"}';
const _probeSimple  = '{"WEB_ATTR_IF_SUPPORT_SHA256": "1", "LD": ""}';
const _probeBase64  = '{"WEB_ATTR_IF_SUPPORT_SHA256": "0", "LD": ""}';
const _loginOk      = '{"result": "sucess"}';
const _loginOkAlt   = '{"result": "success"}';
const _loginBadPw   = '{"result": "TE_WRONG_PASSWORD"}';
const _loginNoField = '{}';
const _cookieStok   = 'stok=abc123def456; Path=/; HttpOnly';
const _cookieZsidn  = 'zsidn=xyz789uvw012; Path=/; HttpOnly';

// ---------------------------------------------------------------------------
void main() {
  final endpoint = RouterEndpoint.fromHost('192.168.0.1');
  final model = RouterModel(
    brand: RouterBrand.zte,
    modelName: 'MF297D',
    hardwareVersion: null,
    firmwareVersion: null,
  );
  const credentials = RouterCredentials(username: 'admin', password: 'admin');

  ZteAuthenticationStrategy _strategy(_FakeZteHttpClient client) =>
      ZteAuthenticationStrategy(
        httpClient: client,
        passwordHasher: const ZtePasswordHasher(),
        sessionExtractor:
            ZteSessionExtractor(logger: const SilentProtocolLogger()),
        logger: const SilentProtocolLogger(),
      );

  // ── Happy path: sha256Chained + stok ─────────────────────────────────────
  group('ZteAuthenticationStrategy — sha256Chained happy path (VERIFIED)', () {
    test('returns Success with stok session', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginOk),
        loginSetCookie: _cookieStok,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrThrow.cookieHeader, equals('stok=abc123def456'));
      expect(result.valueOrThrow.isExpired, isFalse);
    });

    test('returns Success with zsidn session (MF297D)', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginOk),
        loginSetCookie: _cookieZsidn,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrThrow.cookieHeader, equals('zsidn=xyz789uvw012'));
    });
  });

  // ── Happy path: sha256Simple ──────────────────────────────────────────────
  group('ZteAuthenticationStrategy — sha256Simple (VERIFIED)', () {
    test('returns Success', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeSimple),
        loginBodyResponse: _j(_loginOk),
        loginSetCookie: _cookieStok,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── Happy path: base64Only (MF253M) ──────────────────────────────────────
  group('ZteAuthenticationStrategy — base64Only (VERIFIED — MF253M)', () {
    test('returns Success', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeBase64),
        loginBodyResponse: _j(_loginOk),
        loginSetCookie: _cookieStok,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── ASSUMED: corrected success spelling ───────────────────────────────────
  group('ZteAuthenticationStrategy — alternate success spelling (ASSUMED)', () {
    test('accepts "success" as well as firmware typo "sucess"', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginOkAlt),
        loginSetCookie: _cookieStok,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── Auth failures (VERIFIED) ──────────────────────────────────────────────
  group('ZteAuthenticationStrategy — auth failures (VERIFIED)', () {
    test('returns AuthFailure for wrong password', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginBadPw),
        loginSetCookie: null,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<AuthFailure>());
    });

    test('returns ParseFailure when result field missing', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginNoField),
        loginSetCookie: null,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ParseFailure>());
    });

    test('returns SessionFailure when Set-Cookie absent after success', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: _j(_probeChained),
        loginBodyResponse: _j(_loginOk),
        loginSetCookie: null,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<SessionFailure>());
    });
  });

  // ── Probe failures (VERIFIED) ─────────────────────────────────────────────
  group('ZteAuthenticationStrategy — probe failures (VERIFIED)', () {
    test('returns ParseFailure when capability field absent', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: {'LD': 'something'},
        loginBodyResponse: {},
        loginSetCookie: null,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ParseFailure>());
    });

    test('returns ParseFailure when sha256Chained but LD token missing', () async {
      final result = await _strategy(_FakeZteHttpClient(
        probeResponse: {'WEB_ATTR_IF_SUPPORT_SHA256': '2'},
        loginBodyResponse: {},
        loginSetCookie: null,
      )).authenticate(endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<ParseFailure>());
    });
  });

  // ── Result<T> sealed type contract ───────────────────────────────────────
  group('Result<T> sealed type', () {
    test('Success.isSuccess is true', () {
      expect(const Success(42).isSuccess, isTrue);
    });
    test('ResultFailure.isFailure is true', () {
      expect(
        ResultFailure<int>(const AuthFailure(message: 'x')).isFailure,
        isTrue,
      );
    });
    test('map transforms value on Success', () {
      expect(const Success(2).map((v) => v * 3).valueOrThrow, equals(6));
    });
    test('map propagates Failure unchanged', () {
      final f = const AuthFailure(message: 'err');
      expect(ResultFailure<int>(f).map((v) => v * 3).failureOrThrow, equals(f));
    });
  });
}
