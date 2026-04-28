import 'package:flutter/material.dart';

/// Futura-based text theme with intentional weight mapping.
///
/// Display/Headline: Bold (w700) or Medium (w500)
/// Body: Book weight (w300) for readability
/// Labels: Medium (w500) for UI controls
class AppTextTheme {
  AppTextTheme._();

  static const _fontFamily = 'Futura';

  static const textTheme = TextTheme(
    // Display — bold, large headlines
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 57,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 45,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 36,
      letterSpacing: 0,
    ),
    // Headline — medium weight
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: 32,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 28,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 24,
      letterSpacing: 0,
    ),
    // Title — medium weight, UI headers
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 22,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
    ),
    // Body — book weight for readability
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300,
      fontSize: 16,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300,
      fontSize: 14,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w300,
      fontSize: 12,
      letterSpacing: 0.4,
    ),
    // Label — medium weight, UI controls
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );
}
