import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme(ColorScheme? dynamicColor) {
    final ColorScheme scheme = dynamicColor ?? ColorScheme.fromSeed(
      seedColor: AppColors.defaultSeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTextStyles.getTextTheme(scheme),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Dark Theme
  static ThemeData darkTheme(ColorScheme? dynamicColor) {
    final ColorScheme scheme = dynamicColor ?? ColorScheme.fromSeed(
      seedColor: AppColors.defaultSeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: AppTextStyles.getTextTheme(scheme),
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // AMOLED Dark Theme
  static ThemeData amoledTheme(ColorScheme? dynamicColor) {
    final ColorScheme baseScheme = dynamicColor ?? ColorScheme.fromSeed(
      seedColor: AppColors.defaultSeed,
      brightness: Brightness.dark,
    );

    final ColorScheme amoledScheme = baseScheme.copyWith(
      surface: AppColors.amoledSurface,
      // background is deprecated in Flutter 3.22+, using surface for background
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: amoledScheme,
      scaffoldBackgroundColor: AppColors.amoledBackground,
      textTheme: AppTextStyles.getTextTheme(amoledScheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.amoledBackground,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // High Contrast Theme
  static ThemeData highContrastTheme(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.defaultSeed,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      surface: isDark ? AppColors.highContrastDarkBackground : AppColors.highContrastLightBackground,
      onSurface: isDark ? AppColors.highContrastDarkText : AppColors.highContrastLightText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTextStyles.getTextTheme(scheme),
    );
  }
}
