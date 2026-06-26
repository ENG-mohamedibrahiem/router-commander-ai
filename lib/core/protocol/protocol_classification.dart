/// Protocol element classification used throughout the data layer.
///
/// Every constant, parameter, or parsing assumption in the ZTE (and future)
/// adapters must carry one of these labels:
///
///  - VERIFIED     → confirmed from firmware JS, packet captures, or hardware
///  - ASSUMED      → plausible based on pattern; must be isolated + guarded
///  - EXPERIMENTAL → untested variation; must never affect VERIFIED paths
///
/// Usage in code:
/// ```dart
/// // classification: VERIFIED — confirmed from MF297D firmware JS
/// static const String _capabilityField = 'WEB_ATTR_IF_SUPPORT_SHA256';
/// ```
enum ProtocolClassification {
  /// Confirmed from firmware JS deobfuscation, packet captures, or physical
  /// hardware testing. Safe to use in production paths.
  verified,

  /// Inferred from patterns or community reports. Must be:
  ///  1. Isolated in its own method or class.
  ///  2. Clearly commented with rationale.
  ///  3. Protected with a runtime fallback.
  ///  4. Unable to degrade a VERIFIED path.
  assumed,

  /// Untested variation — safe only when completely isolated and behind
  /// an explicit opt-in capability check.
  experimental;

  @override
  String toString() => name.toUpperCase();
}
