import 'package:flutter/material.dart';

/// Rich Burgundy palette color schemes for light and dark modes.
///
/// Primary: Deep Burgundy (#8B2252)
/// Secondary: Warm Espresso (#5C4033)
/// Tertiary: Antique Gold (#C7953C)
class AppColors {
  AppColors._();

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    // Primary
    primary: Color(0xFF8B2252),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFD9E2),
    onPrimaryContainer: Color(0xFF3B0017),
    primaryFixed: Color(0xFFFFD9E2),
    primaryFixedDim: Color(0xFFFFB1C8),
    onPrimaryFixed: Color(0xFF3B0017),
    onPrimaryFixedVariant: Color(0xFF6E0A3B),
    // Secondary
    secondary: Color(0xFF5C4033),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDCC8),
    onSecondaryContainer: Color(0xFF231200),
    secondaryFixed: Color(0xFFFFDCC8),
    secondaryFixedDim: Color(0xFFD7C0B2),
    onSecondaryFixed: Color(0xFF231200),
    onSecondaryFixedVariant: Color(0xFF44291E),
    // Tertiary
    tertiary: Color(0xFFC7953C),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFDEA6),
    onTertiaryContainer: Color(0xFF291800),
    tertiaryFixed: Color(0xFFFFDEA6),
    tertiaryFixedDim: Color(0xFFE8C476),
    onTertiaryFixed: Color(0xFF291800),
    onTertiaryFixedVariant: Color(0xFF5E4100),
    // Error
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    // Surface — warm tinted, not pure white
    surface: Color(0xFFFFF8F6),
    onSurface: Color(0xFF22191B),
    onSurfaceVariant: Color(0xFF534347),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFFF0F2),
    surfaceContainer: Color(0xFFFCE8EB),
    surfaceContainerHigh: Color(0xFFF6E2E5),
    surfaceContainerHighest: Color(0xFFF0DCDF),
    surfaceDim: Color(0xFFE4D6D9),
    surfaceBright: Color(0xFFFFF8F6),
    // Inverse
    inverseSurface: Color(0xFF382E30),
    onInverseSurface: Color(0xFFFEEDEF),
    inversePrimary: Color(0xFFFFB1C8),
    // Outline
    outline: Color(0xFF857377),
    outlineVariant: Color(0xFFD7C1C5),
    // Misc
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF8B2252),
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary
    primary: Color(0xFFFFB1C8),
    onPrimary: Color(0xFF5B0029),
    primaryContainer: Color(0xFF6E0A3B),
    onPrimaryContainer: Color(0xFFFFD9E2),
    primaryFixed: Color(0xFFFFD9E2),
    primaryFixedDim: Color(0xFFFFB1C8),
    onPrimaryFixed: Color(0xFF3B0017),
    onPrimaryFixedVariant: Color(0xFF6E0A3B),
    // Secondary
    secondary: Color(0xFFD7C0B2),
    onSecondary: Color(0xFF3A2418),
    secondaryContainer: Color(0xFF44291E),
    onSecondaryContainer: Color(0xFFFFDCC8),
    secondaryFixed: Color(0xFFFFDCC8),
    secondaryFixedDim: Color(0xFFD7C0B2),
    onSecondaryFixed: Color(0xFF231200),
    onSecondaryFixedVariant: Color(0xFF44291E),
    // Tertiary
    tertiary: Color(0xFFE8C476),
    onTertiary: Color(0xFF422C00),
    tertiaryContainer: Color(0xFF5E4100),
    onTertiaryContainer: Color(0xFFFFDEA6),
    tertiaryFixed: Color(0xFFFFDEA6),
    tertiaryFixedDim: Color(0xFFE8C476),
    onTertiaryFixed: Color(0xFF291800),
    onTertiaryFixedVariant: Color(0xFF5E4100),
    // Error
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    // Surface — warm dark, not pure black
    surface: Color(0xFF1A1114),
    onSurface: Color(0xFFF0DCDF),
    onSurfaceVariant: Color(0xFFD7C1C5),
    surfaceContainerLowest: Color(0xFF140C0E),
    surfaceContainerLow: Color(0xFF22191B),
    surfaceContainer: Color(0xFF271D1F),
    surfaceContainerHigh: Color(0xFF312729),
    surfaceContainerHighest: Color(0xFF3D3234),
    surfaceDim: Color(0xFF1A1114),
    surfaceBright: Color(0xFF413739),
    // Inverse
    inverseSurface: Color(0xFFF0DCDF),
    onInverseSurface: Color(0xFF382E30),
    inversePrimary: Color(0xFF8B2252),
    // Outline
    outline: Color(0xFFA08C90),
    outlineVariant: Color(0xFF534347),
    // Misc
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFFFFB1C8),
  );

  // Brand accent colors for special use cases
  static const burgundy = Color(0xFF8B2252);
  static const espresso = Color(0xFF5C4033);
  static const gold = Color(0xFFC7953C);

  // Status colors (used alongside theme colorScheme)
  static const statusGreen = Color(0xFF2E7D32);
  static const statusGreenDark = Color(0xFF81C784);
}
