import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/app_database.dart';

import '../../services/metadata/local_audio_service.dart';
import '../../services/metadata/online_audio_service.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../../data/repositories/lyrics_repository_impl.dart';

// Provides the singleton database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final localAudioServiceProvider = Provider<LocalAudioService>((ref) {
  return LocalAudioService();
});

// Provides the online audio service API
final onlineAudioServiceProvider = Provider<OnlineAudioService>((ref) {
  return YoutubeAudioService();
});

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LyricsRepositoryImpl(db);
});
