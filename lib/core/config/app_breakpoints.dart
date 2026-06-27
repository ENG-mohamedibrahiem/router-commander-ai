import 'package:responsive_framework/responsive_framework.dart';

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

  static const double maxContentWidth = 1200;
  static const double railWidth = 72;

  static const List<Breakpoint> responsiveBreakpoints = [
    Breakpoint(start: 0, end: compact, name: MOBILE),
    Breakpoint(start: compact, end: medium, name: TABLET),
    Breakpoint(start: medium, end: expanded, name: DESKTOP),
    Breakpoint(start: expanded, end: double.infinity, name: '4K'),
  ];
}
