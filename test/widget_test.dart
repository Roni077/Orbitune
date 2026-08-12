import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/native.dart';
import 'package:just_audio/just_audio.dart';

import 'package:orbitune/main.dart';
import 'package:orbitune/data/datasources/local/app_database.dart';
import 'package:orbitune/data/repositories/track_repository_impl.dart';
import 'package:orbitune/data/repositories/playlist_repository_impl.dart';
import 'package:orbitune/data/repositories/history_repository_impl.dart';
import 'package:orbitune/data/repositories/favorites_repository_impl.dart';
import 'package:orbitune/domain/repositories/track_repository.dart';
import 'package:orbitune/domain/repositories/playlist_repository.dart';
import 'package:orbitune/domain/repositories/history_repository.dart';
import 'package:orbitune/domain/repositories/favorites_repository.dart';
import 'package:orbitune/core/helpers/providers.dart';
import 'package:orbitune/core/helpers/settings_provider.dart';
import 'package:orbitune/core/helpers/network_state_provider.dart';
import 'package:orbitune/ui/features/home/viewmodels/home_viewmodel.dart';
import 'package:orbitune/services/audio/audio_service_provider.dart';
import 'package:orbitune/services/audio/audio_player_handler.dart';

class DummyAudioHandler extends BaseAudioHandler implements AudioPlayerHandler {
  @override
  final AndroidEqualizer equalizer = AndroidEqualizer();
  
  @override
  final AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();
  
  @override
  double get pitch => 1.0;

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {}
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> setPitch(double pitch) async {}
  @override
  Future<void> setSleepTimer(Duration duration) async {}
  @override
  Future<void> cancelSleepTimer() async {}
  @override
  Future<void> stopAfterCurrentSong() async {}
  @override
  Future<void> loadPlaylist(List<MediaItem> items, {int initialIndex = 0}) async {}
  @override
  Future<void> skipToQueueItem(int index) async {}
  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {}
}

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();

    final db = AppDatabase(NativeDatabase.memory());
    final trackRepo = TrackRepositoryImpl(db);
    final playlistRepo = PlaylistRepositoryImpl(db);
    final historyRepo = HistoryRepositoryImpl(db);
    final favoritesRepo = FavoritesRepositoryImpl(db);
    final audioHandler = DummyAudioHandler();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
        trackRepositoryProvider.overrideWithValue(trackRepo),
        playlistRepositoryProvider.overrideWithValue(playlistRepo),
        historyRepositoryProvider.overrideWithValue(historyRepo),
        favoritesRepositoryProvider.overrideWithValue(favoritesRepo),
        audioHandlerProvider.overrideWithValue(audioHandler),
        networkStateProvider.overrideWith((ref) => Stream.value(false)),
        homeLocalTracksProvider.overrideWith((ref) async => []),
        recentlyAddedProvider.overrideWith((ref) async => []),
        madeForYouProvider.overrideWith((ref) async => []),
        trendingProvider.overrideWith((ref) async => []),
        newReleasesProvider.overrideWith((ref) async => []),
        chartsProvider.overrideWith((ref) async => []),
        genresAndMoodsProvider.overrideWith((ref) async => []),
        quickPicksProvider.overrideWith((ref) async => []),
        recentlyPlayedProvider.overrideWith((ref) async => []),
      ],
      child: const OrbituneApp(),
    ));

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Orbitune'), findsWidgets);
    
    await db.close();
  });
}
