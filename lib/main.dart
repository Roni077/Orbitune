import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/dynamic_color_builder.dart';
import 'ui/core/navigation/app_router.dart';

import 'core/helpers/providers.dart';
import 'core/helpers/settings_provider.dart';

import 'services/audio/audio_service_provider.dart';
import 'data/datasources/local/app_database.dart';
import 'data/repositories/track_repository_impl.dart';
import 'data/repositories/playlist_repository_impl.dart';
import 'data/repositories/history_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'domain/repositories/track_repository.dart';
import 'domain/repositories/playlist_repository.dart';
import 'domain/repositories/history_repository.dart';
import 'domain/repositories/favorites_repository.dart';
import 'services/metadata/online_audio_service.dart';

import 'services/audio/proxy_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB
  PaintingBinding.instance.imageCache.maximumSize = 100; // 100 images
  
  final prefs = await SharedPreferences.getInstance();
  
  final db = AppDatabase();
  final trackRepo = TrackRepositoryImpl(db);
  final playlistRepo = PlaylistRepositoryImpl(db);
  final historyRepo = HistoryRepositoryImpl(db);
  final favoritesRepo = FavoritesRepositoryImpl(db);
  
  final onlineAudioService = YoutubeAudioService();
  
  final audioHandler = await initAudioService(trackRepo, prefs, onlineAudioService, historyRepo);
  
  await AudioProxyServer.start();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        trackRepositoryProvider.overrideWithValue(trackRepo),
        playlistRepositoryProvider.overrideWithValue(playlistRepo),
        historyRepositoryProvider.overrideWithValue(historyRepo),
        favoritesRepositoryProvider.overrideWithValue(favoritesRepo),
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
    final router = ref.watch(goRouterProvider);

    return DynamicColorBuilderWidget(
      builder: (context, lightTheme, darkTheme, themeMode) {
        return MaterialApp.router(
          title: 'Orbitune',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
