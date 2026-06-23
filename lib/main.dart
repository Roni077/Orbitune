import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'themes/app_theme.dart';
import 'themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize GetIt, Isar, Hive, AudioService here in subsequent phases.
  
  runApp(
    const ProviderScope(
      child: OrbituneApp(),
    ),
  );
}

class OrbituneApp extends ConsumerWidget {
  const OrbituneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ThemeData theme;
        ThemeData darkTheme;

        if (themeState.themeType == ThemeType.highContrast) {
          theme = AppTheme.highContrastTheme(context);
          darkTheme = AppTheme.highContrastTheme(context);
        } else if (themeState.themeType == ThemeType.amoled) {
          theme = AppTheme.lightTheme(themeState.useDynamicColor ? lightDynamic : null);
          darkTheme = AppTheme.amoledTheme(themeState.useDynamicColor ? darkDynamic : null);
        } else {
          theme = AppTheme.lightTheme(themeState.useDynamicColor ? lightDynamic : null);
          darkTheme = AppTheme.darkTheme(themeState.useDynamicColor ? darkDynamic : null);
        }

        return MaterialApp(
          title: 'Orbitune',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ref.read(themeProvider.notifier).themeMode,
          // TODO: Replace with GoRouter in Phase 3
          home: const Scaffold(
            body: Center(
              child: Text('Orbitune - Theming Initialized'),
            ),
          ),
        );
      },
    );
  }
}
