/// Describes which password-hashing variant is active on a ZTE router.
///
/// The variant is determined at runtime by reading [kZteAuthCapabilityField]
/// (WEB_ATTR_IF_SUPPORT_SHA256) during the capability probe.
/// It must NEVER be hardcoded.
///
/// | Variant        | Capability | Algorithm                             |
/// |----------------|-----------|---------------------------------------|
/// | sha256Chained  | '2'       | sha256( sha256(password) + LD_token ) |
/// | sha256Simple   | '1'       | sha256( base64(password) )            |
/// | base64Only     | '0'       | base64( password )                    |
///
/// classification source: VERIFIED — MF297D firmware JS deobfuscation.
enum ZteAuthVariant {
  /// sha256( sha256(password) + LD_token )
  /// classification: VERIFIED
  sha256Chained,

  /// sha256( base64(password) )
  /// classification: VERIFIED
  sha256Simple,

  /// base64( password ) — legacy models such as MF253M.
  /// classification: VERIFIED
  base64Only;

  /// Parses the raw capability string returned by the router.
  ///
  /// Returns null for unknown values so the caller can log and fall back
  /// rather than crash. NEVER discard a null return without logging.
  static ZteAuthVariant? fromRaw(String raw) => switch (raw.trim()) {
        '2' => sha256Chained,
        '1' => sha256Simple,
        '0' => base64Only,
        _ => null,
      };

  String get label => switch (this) {
        sha256Chained => 'SHA256_CHAINED (variant=2)',
        sha256Simple => 'SHA256_SIMPLE (variant=1)',
        base64Only => 'BASE64_ONLY (variant=0)',
      };
}
