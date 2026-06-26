import 'protocol_classification.dart';

/// Structured protocol-event logger contract.
///
/// The data layer calls this — never print() or Logger directly —
/// so protocol events are observable, testable, and filterable.
abstract interface class ProtocolLogger {
  void logVerifiedSuccess({
    required String adapter,
    required String operation,
    String? detail,
  });

  void logFallback({
    required String adapter,
    required String operation,
    required ProtocolClassification classification,
    required String reason,
    String? fallbackUsed,
  });

  void logProtocolViolation({
    required String adapter,
    required String operation,
    required String reason,
    Object? rawResponse,
  });

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
  void logVerifiedSuccess(
      {required String adapter,
      required String operation,
      String? detail}) {}

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
