import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/helpers/providers.dart';
import '../../../../services/lyrics/lrclib_service.dart';

final lrcLibServiceProvider = Provider<LrcLibService>((ref) {
  return LrcLibService();
});

final lyricsProvider = FutureProvider.family<Map<String, String?>?, MediaItem>((ref, mediaItem) async {
  final lrcLib = ref.read(lrcLibServiceProvider);
  final repo = ref.read(lyricsRepositoryProvider);
  
  // 0. Check cache first
  final cacheResult = await repo.getCachedLyrics(mediaItem.id);
  final cachedData = cacheResult.getOrElse((_) => {});
  if (cachedData.isNotEmpty) {
    return cachedData;
  }
  
  final trackName = mediaItem.title;
  final artistName = mediaItem.artist ?? '';
  final durationMs = mediaItem.duration?.inMilliseconds ?? 0;
  
  // 1. Try LRCLIB for synced/plain lyrics
  if (artistName.isNotEmpty && trackName.isNotEmpty) {
    final result = await lrcLib.getLyrics(trackName, artistName, durationMs);
    final data = result.getOrElse((_) => {});
    if (data.isNotEmpty) {
      await repo.saveLyrics(mediaItem.id, data);
      return data;
    }
  }

  // 2. Fallback to our existing online providers if LRCLIB fails (plain text only)
  if (!mediaItem.id.contains('/')) {
    final onlineService = ref.read(onlineAudioServiceProvider);
    final result = await onlineService.getLyrics(mediaItem.id);
    final plainLyrics = result.getOrElse((_) => '');
    if (plainLyrics.isNotEmpty) {
      final data = {
        'syncedLyrics': null,
        'plainLyrics': plainLyrics,
      };
      await repo.saveLyrics(mediaItem.id, data);
      return data;
    }
  }
  
  return null;
});
