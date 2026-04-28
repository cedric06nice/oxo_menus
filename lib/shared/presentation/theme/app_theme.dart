import 'package:flutter/material.dart';
import 'package:oxo_menus/shared/presentation/theme/app_colors.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';
import 'package:oxo_menus/shared/presentation/theme/app_text_theme.dart';

class AppTheme {
  AppTheme._();

  static final light = _buildTheme(AppColors.lightColorScheme);
  static final dark = _buildTheme(AppColors.darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    final radius = BorderRadius.circular(AppRadius.md);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: AppTextTheme.textTheme,
      fontFamily: 'Futura',

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerLow,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextTheme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: AppElevation.low,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: AppElevation.high,
      ),

      // Chip
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: AppTextTheme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        side: BorderSide.none,
      ),

      // Navigation Bar (bottom, mobile)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          final style = AppTextTheme.textTheme.labelSmall!;
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            );
          }
          return style.copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        elevation: 2,
        height: 64,
      ),

      // Navigation Rail (tablet)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: colorScheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: AppTextTheme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTextTheme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Navigation Drawer (desktop)
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        tileHeight: 48,
        labelTextStyle: WidgetStateTextStyle.resolveWith((states) {
          final style = AppTextTheme.textTheme.labelLarge!;
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            );
          }
          return style.copyWith(color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          elevation: AppElevation.low,
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: AppElevation.medium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: radius),
        titleTextStyle: AppTextTheme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextTheme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.5,
        space: 0.5,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
        backgroundColor: isLight
            ? colorScheme.inverseSurface
            : colorScheme.surfaceContainerHighest,
        contentTextStyle: AppTextTheme.textTheme.bodyMedium?.copyWith(
          color: isLight ? colorScheme.onInverseSurface : colorScheme.onSurface,
        ),
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: radius),
        elevation: AppElevation.medium,
        color: colorScheme.surfaceContainerHigh,
      ),

      // SegmentedButton
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: radius),
          ),
        ),
      ),

      // TabBar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTextTheme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primaryContainer,
      ),
    );
  }
}
