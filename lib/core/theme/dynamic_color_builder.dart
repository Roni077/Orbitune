import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'dynamic_album_color_provider.dart';
import '../helpers/settings_provider.dart';

class DynamicColorBuilderWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, ThemeData lightTheme, ThemeData darkTheme, ThemeMode themeMode) builder;

  const DynamicColorBuilderWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final settings = ref.watch(settingsProvider);
        final themeMode = settings.themeMode;
        final isAmoled = settings.amoledMode;
        final useDynamic = settings.dynamicColors;
        final customAccentColor = Color(settings.accentColor);
        
        final albumColorScheme = ref.watch(dynamicAlbumColorSchemeProvider);
        
        // Ensure the extractor runs
        ref.watch(albumColorExtractorProvider);

        ThemeData lightTheme = AppTheme.lightTheme;
        ThemeData darkTheme = isAmoled ? AppTheme.amoledTheme : AppTheme.darkTheme;

        // Base color schemes
        ColorScheme currentLightScheme = lightTheme.colorScheme;
        ColorScheme currentDarkScheme = darkTheme.colorScheme;

        if (albumColorScheme != null) {
          // Album colors take highest precedence when playing
          currentLightScheme = albumColorScheme;
          currentDarkScheme = albumColorScheme;
        } else if (useDynamic && lightDynamic != null && darkDynamic != null) {
          // Use Material You dynamic colors
          currentLightScheme = lightDynamic;
          currentDarkScheme = darkDynamic;
        } else {
          // Fallback to custom accent color
          currentLightScheme = ColorScheme.fromSeed(
            seedColor: customAccentColor,
            brightness: Brightness.light,
          );
          currentDarkScheme = ColorScheme.fromSeed(
            seedColor: customAccentColor,
            brightness: Brightness.dark,
          );
          
          if (isAmoled) {
            currentDarkScheme = currentDarkScheme.copyWith(
              surface: Colors.black,
            );
          }
        }

        lightTheme = lightTheme.copyWith(colorScheme: currentLightScheme);
        darkTheme = darkTheme.copyWith(colorScheme: currentDarkScheme);

        return builder(context, lightTheme, darkTheme, themeMode);
      },
    );
  }
}
