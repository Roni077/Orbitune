import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:audio_service/audio_service.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';
import 'themes/theme_provider.dart';
import 'features/player/orbitune_audio_handler.dart';
import 'features/player/player_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background audio handler
  final audioHandler = await AudioService.init(
    builder: () => OrbituneAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.orbitune.audio',
      androidNotificationChannelName: 'Orbitune Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  
  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const OrbituneApp(),
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

        return MaterialApp.router(
          title: 'Orbitune',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ref.read(themeProvider.notifier).themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
