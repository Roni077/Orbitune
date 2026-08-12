import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/providers.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../core/permissions/permission_manager.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../domain/repositories/track_repository.dart';

final recentlyPlayedProvider = FutureProvider<List<Track>>((ref) async {
  final repo = ref.read(trackRepositoryProvider);
  final result = await repo.getRecentlyPlayed(limit: 10);
  return result.getOrElse((_) => []);
});

final quickPicksProvider = FutureProvider<List<Track>>((ref) async {
  final ytService = ref.read(onlineAudioServiceProvider);
  // Just use a default search like 'Top hits' for quick picks
  final result = await ytService.searchSongs('Top hits');
  return result.getOrElse((_) => []);
});

final madeForYouProvider = FutureProvider<List<Track>>((ref) async {
  final historyRepo = ref.read(historyRepositoryProvider);
  final ytService = ref.read(onlineAudioServiceProvider);
  
  final artistsResult = await historyRepo.getTopArtists(3);
  final topArtists = artistsResult.getOrElse((_) => []);
  
  if (topArtists.isEmpty) {
    // Fallback if no history
    final result = await ytService.searchSongs('Discover weekly');
    return result.getOrElse((_) => []);
  }

  final List<Track> mixTracks = [];
  for (final artist in topArtists) {
    final result = await ytService.searchSongs(artist);
    result.fold(
      (l) => null,
      (tracks) => mixTracks.addAll(tracks.take(5)),
    );
  }
  
  mixTracks.shuffle();
  return mixTracks;
});

final trendingProvider = FutureProvider<List<Track>>((ref) async {
  final ytService = ref.read(onlineAudioServiceProvider);
  final result = await ytService.getTrendingSongs();
  return result.getOrElse((_) => []);
});

final newReleasesProvider = FutureProvider<List<Track>>((ref) async {
  final ytService = ref.read(onlineAudioServiceProvider);
  final result = await ytService.getNewReleases();
  return result.getOrElse((_) => []);
});

final chartsProvider = FutureProvider<List<Track>>((ref) async {
  final ytService = ref.read(onlineAudioServiceProvider);
  final result = await ytService.getCharts();
  return result.getOrElse((_) => []);
});

final homeLocalTracksProvider = FutureProvider<List<Track>>((ref) async {
  final hasPermission = await PermissionManager.requestStoragePermission();
  await PermissionManager.requestNotificationPermission();

  if (!hasPermission) {
    throw Exception('Storage permission denied.');
  }

  final localAudioService = ref.read(localAudioServiceProvider);
  final settings = ref.read(settingsProvider);
  final result = await localAudioService.getLocalSongs(selectedFolders: settings.selectedFolders);
  
  return result.getOrElse((_) => []);
});

final recentlyAddedProvider = FutureProvider<List<Track>>((ref) async {
  final hasPermission = await PermissionManager.requestStoragePermission();
  if (!hasPermission) return [];

  final localAudioService = ref.read(localAudioServiceProvider);
  final settings = ref.read(settingsProvider);
  final result = await localAudioService.getLocalSongs(selectedFolders: settings.selectedFolders);
  
  final tracks = result.getOrElse((_) => []);
  // Assuming the track ID is the file path, we can sort by file modification date
  // Since sorting many files synchronously might be slow, we just return the end of the list if it's already sorted by local audio service, 
  // or we can just return the first 10 for now as a mock "recently added" since we don't have file modification date on Track entity yet.
  return tracks.take(10).toList();
});

final genresAndMoodsProvider = FutureProvider<List<OnlineItem>>((ref) async {
  final ytService = ref.read(onlineAudioServiceProvider);
  final result = await ytService.getGenresAndMoods();
  return result.getOrElse((_) => []);
});
