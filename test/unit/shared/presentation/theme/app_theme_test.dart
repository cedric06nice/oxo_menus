import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/shared/presentation/theme/app_colors.dart';
import 'package:oxo_menus/shared/presentation/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('light theme', () {
      test('should use Material 3', () {
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('should have light brightness', () {
        expect(AppTheme.light.brightness, Brightness.light);
      });

      test('should use burgundy primary color', () {
        expect(
          AppTheme.light.colorScheme.primary,
          AppColors.lightColorScheme.primary,
        );
      });

      test('should use Futura font family', () {
        expect(AppTheme.light.textTheme.bodyLarge?.fontFamily, 'Futura');
      });

      test('should configure filled input decoration', () {
        final inputTheme = AppTheme.light.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.border, isA<OutlineInputBorder>());
      });

      test('should configure filled button theme', () {
        final buttonTheme = AppTheme.light.filledButtonTheme;
        final style = buttonTheme.style;
        expect(style, isNotNull);
        // FilledButton should have minimum size and shape configured
        final minimumSize = style!.minimumSize?.resolve({});
        expect(minimumSize?.height, greaterThanOrEqualTo(48));
      });

      test('should configure card theme', () {
        final cardTheme = AppTheme.light.cardTheme;
        expect(cardTheme.clipBehavior, Clip.antiAlias);
        expect(cardTheme.elevation, 1);
      });

      test('should configure appBar theme', () {
        final appBarTheme = AppTheme.light.appBarTheme;
        expect(appBarTheme.elevation, 0);
        expect(appBarTheme.centerTitle, false);
      });

      test('should configure navigation bar theme', () {
        expect(AppTheme.light.navigationBarTheme.backgroundColor, isNotNull);
      });

      test('should configure navigation rail theme', () {
        expect(AppTheme.light.navigationRailTheme.backgroundColor, isNotNull);
      });
    });

    group('dark theme', () {
      test('should use Material 3', () {
        expect(AppTheme.dark.useMaterial3, isTrue);
      });

      test('should have dark brightness', () {
        expect(AppTheme.dark.brightness, Brightness.dark);
      });

      test('should use burgundy primary color (dark variant)', () {
        expect(
          AppTheme.dark.colorScheme.primary,
          AppColors.darkColorScheme.primary,
        );
      });

      test('should use Futura font family', () {
        expect(AppTheme.dark.textTheme.bodyLarge?.fontFamily, 'Futura');
      });

      test('should configure filled input decoration', () {
        final inputTheme = AppTheme.dark.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.border, isA<OutlineInputBorder>());
      });
    });
  });
}
