import 'protocol_classification.dart';

/// Structured protocol-event logger contract.
///
/// The data layer calls this logger — never print() or Logger directly —
/// so that protocol events are observable, testable, and filterable.
abstract interface class ProtocolLogger {
  /// A VERIFIED request/response cycle completed normally.
  void logVerifiedSuccess({
    required String adapter,
    required String operation,
    String? detail,
  });

  /// A protocol element with [classification] triggered its fallback.
  /// This is not an error — it is expected variance. Log it clearly.
  void logFallback({
    required String adapter,
    required String operation,
    required ProtocolClassification classification,
    required String reason,
    String? fallbackUsed,
  });

  /// A VERIFIED protocol contract was violated by the router.
  /// This is always an error worth investigating.
  void logProtocolViolation({
    required String adapter,
    required String operation,
    required String reason,
    Object? rawResponse,
  });

  /// A capability was detected at runtime that changes behaviour.
  void logCapabilityDetected({
    required String adapter,
    required String capability,
    required String detectedValue,
  });
}

/// No-op implementation used in tests that do not care about log output.
final class SilentProtocolLogger implements ProtocolLogger {
  const SilentProtocolLogger();

  @override
  void logVerifiedSuccess({
    required String adapter,
    required String operation,
    String? detail,
  }) {}

  @override
  void logFallback({
    required String adapter,
    required String operation,
    required ProtocolClassification classification,
    required String reason,
    String? fallbackUsed,
  }) {}

  @override
  void logProtocolViolation({
    required String adapter,
    required String operation,
    required String reason,
    Object? rawResponse,
  }) {}

  @override
  void logCapabilityDetected({
    required String adapter,
    required String capability,
    required String detectedValue,
  }) {}
}
