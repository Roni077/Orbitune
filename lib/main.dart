import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:audio_service/audio_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';
import 'themes/theme_provider.dart';
import 'features/player/orbitune_audio_handler.dart';
import 'features/player/player_providers.dart';
import 'core/providers.dart';
import 'data/models/audio_model.dart';
import 'data/models/playlist_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize background audio handler
  final audioHandler = await AudioService.init(
    builder: () => OrbituneAudioHandler(prefs),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.orbitune.audio',
      androidNotificationChannelName: 'Orbitune Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
  
  // Initialize Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [AudioModelSchema, PlaylistModelSchema],
    directory: dir.path,
  );
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        audioHandlerProvider.overrideWithValue(audioHandler),
        isarProvider.overrideWithValue(isar),
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

        final audioHandler = ref.read(audioHandlerProvider);

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () {
              if (audioHandler.playbackState.value.playing) {
                audioHandler.pause();
              } else {
                audioHandler.play();
              }
            },
            const SingleActivator(LogicalKeyboardKey.mediaTrackNext): () => audioHandler.skipToNext(),
            const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () => audioHandler.skipToPrevious(),
            const SingleActivator(LogicalKeyboardKey.space, control: true): () {
              if (audioHandler.playbackState.value.playing) {
                audioHandler.pause();
              } else {
                audioHandler.play();
              }
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight, control: true): () => audioHandler.skipToNext(),
            const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true): () => audioHandler.skipToPrevious(),
          },
          child: Focus(
            autofocus: true,
            child: MaterialApp.router(
              title: 'Orbitune',
              theme: theme,
              darkTheme: darkTheme,
              themeMode: ref.read(themeProvider.notifier).themeMode,
              routerConfig: ref.watch(routerProvider),
            ),
          ),
        );
      },
    );
  }
}
