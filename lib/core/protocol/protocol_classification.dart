/// Classifies the confidence level of a protocol implementation element.
///
/// Every field, endpoint, and auth step in the ZTE/TP-Link adapters
/// must carry one of these classifications, enforced via [ProtocolLogger].
enum ProtocolClassification {
  /// Confirmed by firmware source code, packet capture, or official docs.
  verified('VERIFIED'),

  /// Based on reverse engineering, forum reports, or logical inference.
  /// Must have a documented fallback strategy.
  assumed('ASSUMED'),

  /// Untested on real hardware. Requires explicit opt-in.
  experimental('EXPERIMENTAL');

  const ProtocolClassification(this.label);
  final String label;
}
