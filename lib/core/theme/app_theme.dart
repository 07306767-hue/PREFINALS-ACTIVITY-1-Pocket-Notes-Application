import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  /// Material 3 light color scheme.
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5266D8)),
    useMaterial3: true,
  );

  /// Material 3 dark color scheme using the same seed color.
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5266D8),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
