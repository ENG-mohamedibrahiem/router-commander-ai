import 'protocol_classification.dart';

/// Structured logger for protocol-level events.
///
/// Every log entry carries:
///   - adapter name (e.g. 'ZTE', 'TP-Link')
///   - operation name (e.g. 'login', 'readWanStatus')
///   - classification (VERIFIED / ASSUMED / EXPERIMENTAL)
///   - human-readable detail
///
/// In production, these logs help triage firmware compatibility issues
/// without requiring a debugger attached to the device.
final class ProtocolLogger {
  const ProtocolLogger();

  void logVerifiedSuccess({
    required String adapter,
    required String operation,
    String? detail,
  }) {
    _emit(
      level: '✅ VERIFIED',
      adapter: adapter,
      operation: operation,
      message: detail ?? 'OK',
    );
  }

  void logFallback({
    required String adapter,
    required String operation,
    required ProtocolClassification classification,
    required String reason,
    required String fallbackUsed,
  }) {
    _emit(
      level: '⚠️  ${classification.label}',
      adapter: adapter,
      operation: operation,
      message: '$reason → fallback: $fallbackUsed',
    );
  }

  void logProtocolViolation({
    required String adapter,
    required String operation,
    required String reason,
    Object? rawResponse,
  }) {
    _emit(
      level: '🚨 VIOLATION',
      adapter: adapter,
      operation: operation,
      message:
          '$reason${rawResponse != null ? ' | raw: $rawResponse' : ''}',
    );
  }

  void logCapabilityDetected({
    required String adapter,
    required String capability,
    required String detectedValue,
  }) {
    _emit(
      level: '🔍 CAPABILITY',
      adapter: adapter,
      operation: capability,
      message: 'detected → $detectedValue',
    );
  }

  void _emit({
    required String level,
    required String adapter,
    required String operation,
    required String message,
  }) {
    // ignore: avoid_print
    print('[$level][$adapter][$operation] $message');
  }
}
