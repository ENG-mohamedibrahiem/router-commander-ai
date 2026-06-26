import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../protocol/zte_auth_variant.dart';

/// Computes the hashed password string expected by the ZTE login endpoint.
///
/// Each [ZteAuthVariant] uses a distinct algorithm confirmed through firmware
/// JS deobfuscation. This class is a pure function — no I/O, fully testable.
///
/// Do NOT call this with a hardcoded variant. The variant must come from
/// a runtime capability probe via [ZteAuthenticationStrategy].
final class ZtePasswordHasher {
  const ZtePasswordHasher();

  /// Computes the login password string for [variant].
  ///
  /// [plainPassword] — the raw password as entered by the user.
  /// [ldToken]       — the LD anti-replay token; ONLY required for
  ///                   [ZteAuthVariant.sha256Chained]; ignored otherwise.
  ///
  /// Throws [ArgumentError] if [ldToken] is null when variant is sha256Chained.
  String hash({
    required String plainPassword,
    required ZteAuthVariant variant,
    String? ldToken,
  }) {
    return switch (variant) {
      // classification: VERIFIED — sha256( sha256(password) + LD )
      // Evidence: MF297D firmware JS deobfuscation.
      ZteAuthVariant.sha256Chained => _sha256Chained(
          plainPassword: plainPassword,
          ldToken: ldToken ??
              (throw ArgumentError(
                'ldToken must not be null for ZteAuthVariant.sha256Chained',
              )),
        ),

      // classification: VERIFIED — sha256( base64(password) )
      // Evidence: MF297D firmware JS (intermediate firmware path).
      ZteAuthVariant.sha256Simple => _sha256Simple(plainPassword),

      // classification: VERIFIED — base64( password )
      // Evidence: MF253M legacy firmware confirmed via community captures.
      ZteAuthVariant.base64Only => _base64Only(plainPassword),
    };
  }

  String _sha256Chained({
    required String plainPassword,
    required String ldToken,
  }) {
    final innerHash = _sha256Hex(plainPassword);
    return _sha256Hex(innerHash + ldToken).toUpperCase();
  }

  String _sha256Simple(String plainPassword) {
    final b64 = base64.encode(utf8.encode(plainPassword));
    return _sha256Hex(b64);
  }

  String _base64Only(String plainPassword) {
    return base64.encode(utf8.encode(plainPassword));
  }

  String _sha256Hex(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
