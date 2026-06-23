import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/audio_model.dart';
import '../library/library_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

// Simple in-memory search history for now. Will be persisted later.
final searchHistoryProvider = StateProvider<List<String>>((ref) => []);

final searchResultsProvider = Provider.autoDispose<List<AudioModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final allSongs = ref.watch(songsStreamProvider).valueOrNull ?? [];

  if (query.isEmpty) return [];

  return allSongs.where((song) {
    return song.title.toLowerCase().contains(query) ||
           song.artist.toLowerCase().contains(query) ||
           song.album.toLowerCase().contains(query);
  }).toList();
});
