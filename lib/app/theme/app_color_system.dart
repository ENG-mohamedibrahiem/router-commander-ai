import 'package:flutter/material.dart';

class AppColorSystem {
  const AppColorSystem._();

  static const Color seed = Color(0xFF006D77);
  static const Color ocean = Color(0xFF006D77);
  static const Color mint = Color(0xFF2A9D8F);
  static const Color amber = Color(0xFFE9C46A);
  static const Color coral = Color(0xFFE76F51);
  static const Color violet = Color(0xFF6D5DD3);
  static const Color sky = Color(0xFF118AB2);
  static const Color critical = Color(0xFFB42318);

  static const LinearGradient commandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ocean, mint, sky],
  );

  static ColorScheme lightScheme() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: ocean,
      secondary: mint,
      tertiary: amber,
      error: critical,
    );
  }

  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: const Color(0xFF7AD7D1),
      secondary: const Color(0xFF90E0C4),
      tertiary: amber,
      error: const Color(0xFFFFB4AB),
    );
  }
}
