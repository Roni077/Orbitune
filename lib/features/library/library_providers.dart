import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../data/models/audio_model.dart';

// Streams the entire library of songs, sorted by track number or date added
final songsStreamProvider = StreamProvider.autoDispose<List<AudioModel>>((ref) {
  final repo = ref.watch(audioRepositoryProvider);
  return repo.watchAllAudios();
});

// Provides recently added songs (limit 20)
final recentlyAddedProvider = FutureProvider.autoDispose<List<AudioModel>>((ref) async {
  final repo = ref.watch(audioRepositoryProvider);
  final all = await repo.getAllAudios();
  all.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
  return all.take(20).toList();
});

// Extracts unique albums
final albumsProvider = Provider.autoDispose<List<String>>((ref) {
  final songs = ref.watch(songsStreamProvider).valueOrNull ?? [];
  return songs.map((s) => s.album).toSet().toList()..sort();
});

// Extracts unique artists
final artistsProvider = Provider.autoDispose<List<String>>((ref) {
  final songs = ref.watch(songsStreamProvider).valueOrNull ?? [];
  return songs.map((s) => s.artist).toSet().toList()..sort();
});

// Status of the media scanner
final isScanningProvider = StateProvider<bool>((ref) => false);

// Multi-select state
final selectedSongsProvider = StateNotifierProvider<SelectedSongsNotifier, Set<String>>((ref) {
  return SelectedSongsNotifier();
});

class SelectedSongsNotifier extends StateNotifier<Set<String>> {
  SelectedSongsNotifier() : super({});

  void toggle(String uri) {
    if (state.contains(uri)) {
      state = {...state}..remove(uri);
    } else {
      state = {...state, uri};
    }
  }

  void clear() => state = {};
  
  void selectAll(List<String> uris) => state = uris.toSet();
}
