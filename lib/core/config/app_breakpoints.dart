import 'package:responsive_framework/responsive_framework.dart';

class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double railWidth = 720;
  static const double maxContentWidth = 1180;

  static const List<Breakpoint> responsiveBreakpoints = [
    Breakpoint(start: 0, end: compact - 1, name: 'COMPACT'),
    Breakpoint(start: compact, end: medium - 1, name: 'MEDIUM'),
    Breakpoint(start: medium, end: expanded - 1, name: 'EXPANDED'),
    Breakpoint(start: expanded, end: double.infinity, name: 'LARGE'),
  ];
}
