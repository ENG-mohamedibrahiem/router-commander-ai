/// Responsive breakpoints — single source of truth.
/// Used by ResponsiveFramework and any manual MediaQuery checks.
abstract final class AppBreakpoints {
  /// < 600 dp  → compact (phone portrait)
  static const double compact = 600;

  /// 600–840 dp → medium (phone landscape / small tablet)
  static const double medium = 840;

  /// 840–1200 dp → expanded (tablet / small desktop)
  static const double expanded = 1200;

  /// ≥ 1200 dp  → large (desktop / TV)
  static const double large = 1600;

  /// Navigation rail appears at or above this width.
  static const double railBreakpoint = medium;
}
