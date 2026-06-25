import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021().black;
    final textColor = colorScheme.onSurface;
    final subtleTextColor = colorScheme.onSurfaceVariant;

    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        height: 1.5,
        color: textColor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.45,
        color: subtleTextColor,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }
}
