// ignore_for_file: lines_longer_than_80_chars
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_commander_ai/core/errors/failure.dart';
import 'package:router_commander_ai/core/protocol/protocol_logger.dart';
import 'package:router_commander_ai/core/utils/result.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_authentication_strategy.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_password_hasher.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_session_extractor.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_brand.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_credentials.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_endpoint.dart';
import 'package:router_commander_ai/features/routers/domain/entities/router_model.dart';

// ---------------------------------------------------------------------------
// Fake HTTP client — deterministic, fixture-based, no real I/O
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

// ---------------------------------------------------------------------------
// Fixture constants — inlined for self-contained tests
// ---------------------------------------------------------------------------

Map<String, dynamic> _j(String s) => jsonDecode(s) as Map<String, dynamic>;

final _probeChained = _j('{"WEB_ATTR_IF_SUPPORT_SHA256":"2","LD":"A1B2C3D4E5F60718"}');
final _probeSimple  = _j('{"WEB_ATTR_IF_SUPPORT_SHA256":"1","LD":""}');
final _probeBase64  = _j('{"WEB_ATTR_IF_SUPPORT_SHA256":"0","LD":""}');
final _loginOk      = _j('{"result":"sucess"}');          // firmware typo
final _loginOkAlt   = _j('{"result":"success"}');         // corrected spelling
final _loginWrong   = _j('{"result":"TE_WRONG_PASSWORD"}');
final _loginNoField = _j('{}');

const _cookieStok  = 'stok=abc123def456; Path=/; HttpOnly';
const _cookieZsidn = 'zsidn=xyz789uvw012; Path=/; HttpOnly';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  final endpoint = const RouterEndpoint(host: '192.168.0.1', port: 80, useHttps: false);
  final model = RouterModel(
    brand: RouterBrand.zte,
    modelName: 'MF297D',
    hardwareVersion: null,
    firmwareVersion: null,
  );
  const credentials =
      RouterCredentials(username: 'admin', password: 'admin');

  ZteAuthenticationStrategy build(_FakeZteHttpClient client) =>
      ZteAuthenticationStrategy(
        httpClient: client,
        passwordHasher: const ZtePasswordHasher(),
        sessionExtractor:
            ZteSessionExtractor(logger: const ProtocolLogger()),
        logger: const ProtocolLogger(),
      );

  // ── Happy path: sha256Chained + stok ─────────────────────────────────────
  group('sha256Chained + stok cookie (VERIFIED)', () {
    test('returns Success with valid session', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginOk,
        loginSetCookie: _cookieStok,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrThrow.cookieHeader, equals('stok=abc123def456'));
      expect(result.valueOrThrow.isExpired, isFalse);
    });

    test('returns Success with zsidn cookie', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginOk,
        loginSetCookie: _cookieZsidn,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);

      expect(result.isSuccess, isTrue);
      expect(
          result.valueOrThrow.cookieHeader, equals('zsidn=xyz789uvw012'));
    });
  });

  // ── Happy path: sha256Simple ──────────────────────────────────────────────
  group('sha256Simple happy path (VERIFIED)', () {
    test('returns Success', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeSimple,
        loginBodyResponse: _loginOk,
        loginSetCookie: _cookieStok,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── Happy path: base64Only (MF253M) ───────────────────────────────────────
  group('base64Only happy path (VERIFIED — MF253M)', () {
    test('returns Success', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeBase64,
        loginBodyResponse: _loginOk,
        loginSetCookie: _cookieStok,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── ASSUMED: corrected success spelling ───────────────────────────────────
  group('corrected "success" spelling (ASSUMED guard)', () {
    test('accepts "success" without failing', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginOkAlt,
        loginSetCookie: _cookieStok,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isSuccess, isTrue);
    });
  });

  // ── Failure: wrong password ───────────────────────────────────────────────
  group('auth failures (VERIFIED)', () {
    test('returns AuthFailure for wrong password', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginWrong,
        loginSetCookie: null,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.isFailure, isTrue);
      expect(result.failureOrThrow, isA<AuthFailure>());
    });

    test('returns ParseFailure when result field missing', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginNoField,
        loginSetCookie: null,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.failureOrThrow, isA<ParseFailure>());
    });

    test('returns SessionFailure when Set-Cookie absent after success',
        () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: _probeChained,
        loginBodyResponse: _loginOk,
        loginSetCookie: null,
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.failureOrThrow, isA<SessionFailure>());
    });
  });

  // ── Failure: probe errors ─────────────────────────────────────────────────
  group('probe failures (VERIFIED)', () {
    test('returns ParseFailure when capability field absent', () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: {'LD': 'something'},
        loginBodyResponse: {},
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
      expect(result.failureOrThrow, isA<ParseFailure>());
    });

    test('returns ParseFailure when sha256Chained but LD token missing',
        () async {
      final result = await build(_FakeZteHttpClient(
        probeResponse: {'WEB_ATTR_IF_SUPPORT_SHA256': '2'},
        loginBodyResponse: {},
      )).authenticate(
          endpoint: endpoint, credentials: credentials, model: model);
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
          isTrue);
    });
    test('map transforms value on Success', () {
      final r = const Success(2).map((v) => v * 3);
      expect(r.valueOrThrow, equals(6));
    });
    test('map propagates Failure unchanged', () {
      final f = const AuthFailure(message: 'err');
      expect(ResultFailure<int>(f).map((v) => v * 3).failureOrThrow,
          equals(f));
    });
  });
}
