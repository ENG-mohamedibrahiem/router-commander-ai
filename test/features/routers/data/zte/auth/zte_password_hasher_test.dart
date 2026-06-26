// ignore_for_file: lines_longer_than_80_chars
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/auth/zte_password_hasher.dart';
import 'package:router_commander_ai/features/routers/data/datasources/zte/protocol/zte_auth_variant.dart';

void main() {
  const hasher = ZtePasswordHasher();

  String sha256Hex(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  // ── sha256Chained (variant=2) ─────────────────────────────────────────────
  group('ZtePasswordHasher — sha256Chained (VERIFIED)', () {
    const password = 'admin';
    const ldToken = 'A1B2C3D4E5F60718';

    test('produces sha256( sha256(password) + LD ).toUpperCase()', () {
      final innerHash = sha256Hex(password);
      final expected = sha256Hex(innerHash + ldToken).toUpperCase();
      final result = hasher.hash(
        plainPassword: password,
        variant: ZteAuthVariant.sha256Chained,
        ldToken: ldToken,
      );
      expect(result, equals(expected));
    });

    test('result is uppercase hex', () {
      final result = hasher.hash(
        plainPassword: password,
        variant: ZteAuthVariant.sha256Chained,
        ldToken: ldToken,
      );
      expect(result, equals(result.toUpperCase()));
    });

    test('throws ArgumentError when ldToken is null', () {
      expect(
        () => hasher.hash(
          plainPassword: password,
          variant: ZteAuthVariant.sha256Chained,
        ),
        throwsArgumentError,
      );
    });

    test('different LD tokens produce different hashes', () {
      final h1 = hasher.hash(
          plainPassword: password,
          variant: ZteAuthVariant.sha256Chained,
          ldToken: 'TOKEN_ONE');
      final h2 = hasher.hash(
          plainPassword: password,
          variant: ZteAuthVariant.sha256Chained,
          ldToken: 'TOKEN_TWO');
      expect(h1, isNot(equals(h2)));
    });
  });

  // ── sha256Simple (variant=1) ──────────────────────────────────────────────
  group('ZtePasswordHasher — sha256Simple (VERIFIED)', () {
    const password = 'admin';

    test('produces sha256( base64(password) )', () {
      final b64 = base64.encode(utf8.encode(password));
      final expected = sha256Hex(b64);
      final result = hasher.hash(
        plainPassword: password,
        variant: ZteAuthVariant.sha256Simple,
      );
      expect(result, equals(expected));
    });

    test('result is lowercase hex', () {
      final result = hasher.hash(
        plainPassword: password,
        variant: ZteAuthVariant.sha256Simple,
      );
      expect(result, equals(result.toLowerCase()));
    });
  });

  // ── base64Only (variant=0) ────────────────────────────────────────────────
  group('ZtePasswordHasher — base64Only (VERIFIED — MF253M legacy)', () {
    const password = 'admin';

    test('produces base64( password )', () {
      final expected = base64.encode(utf8.encode(password));
      final result = hasher.hash(
        plainPassword: password,
        variant: ZteAuthVariant.base64Only,
      );
      expect(result, equals(expected));
    });

    test('empty password produces valid base64', () {
      final result = hasher.hash(
        plainPassword: '',
        variant: ZteAuthVariant.base64Only,
      );
      expect(result, equals(base64.encode(utf8.encode(''))));
    });
  });

  // ── ZteAuthVariant.fromRaw ────────────────────────────────────────────────
  group('ZteAuthVariant.fromRaw', () {
    test('parses "2" → sha256Chained', () {
      expect(ZteAuthVariant.fromRaw('2'), ZteAuthVariant.sha256Chained);
    });
    test('parses "1" → sha256Simple', () {
      expect(ZteAuthVariant.fromRaw('1'), ZteAuthVariant.sha256Simple);
    });
    test('parses "0" → base64Only', () {
      expect(ZteAuthVariant.fromRaw('0'), ZteAuthVariant.base64Only);
    });
    test('returns null for unknown value', () {
      expect(ZteAuthVariant.fromRaw('99'), isNull);
    });
    test('trims whitespace before parsing', () {
      expect(ZteAuthVariant.fromRaw(' 2 '), ZteAuthVariant.sha256Chained);
    });
  });
}
