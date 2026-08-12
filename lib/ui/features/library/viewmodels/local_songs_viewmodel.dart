import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/repositories/track_repository.dart';
import '../../../../domain/entities/track.dart';
import '../../../../core/helpers/providers.dart';
import '../../../../core/helpers/settings_provider.dart';

enum TrackSortOption { title, artist, duration, dateAdded, recentlyPlayed }

class LocalSongsState {
  final AsyncValue<List<Track>> tracks;
  final String searchQuery;
  final TrackSortOption sortOption;
  final bool ascending;
  final bool isSelectionMode;
  final Set<String> selectedTrackIds;

  LocalSongsState({
    required this.tracks,
    this.searchQuery = '',
    this.sortOption = TrackSortOption.title,
    this.ascending = true,
    this.isSelectionMode = false,
    this.selectedTrackIds = const {},
  });

  LocalSongsState copyWith({
    AsyncValue<List<Track>>? tracks,
    String? searchQuery,
    TrackSortOption? sortOption,
    bool? ascending,
    bool? isSelectionMode,
    Set<String>? selectedTrackIds,
  }) {
    return LocalSongsState(
      tracks: tracks ?? this.tracks,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedTrackIds: selectedTrackIds ?? this.selectedTrackIds,
    );
  }
}

final localSongsViewModelProvider = NotifierProvider<LocalSongsViewModel, LocalSongsState>(() {
  return LocalSongsViewModel();
});

class LocalSongsViewModel extends Notifier<LocalSongsState> {
  List<Track> _rawTracks = [];

  @override
  LocalSongsState build() {
    loadLocalSongs();
    return LocalSongsState(tracks: const AsyncValue.loading());
  }

  Future<void> loadLocalSongs() async {
    state = state.copyWith(tracks: const AsyncValue.loading());
    final localService = ref.read(localAudioServiceProvider);
    final settings = ref.read(settingsProvider);
    
    final result = await localService.getLocalSongs(selectedFolders: settings.selectedFolders);

    result.match(
      (failure) => state = state.copyWith(tracks: AsyncValue.error(failure.message, StackTrace.current)),
      (tracks) {
        _rawTracks = tracks;
        _applyFiltersAndSort();
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  void setSortOption(TrackSortOption option) {
    if (state.sortOption == option) {
      state = state.copyWith(ascending: !state.ascending);
    } else {
      state = state.copyWith(sortOption: option, ascending: true);
    }
    _applyFiltersAndSort();
  }

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedTrackIds: {},
    );
  }

  void toggleTrackSelection(String trackId) {
    final newSelection = Set<String>.from(state.selectedTrackIds);
    if (newSelection.contains(trackId)) {
      newSelection.remove(trackId);
    } else {
      newSelection.add(trackId);
    }
    state = state.copyWith(selectedTrackIds: newSelection);
  }

  void selectAll() {
    state.tracks.whenData((tracks) {
      final allIds = tracks.map((t) => t.id).toSet();
      state = state.copyWith(selectedTrackIds: allIds);
    });
  }

  void clearSelection() {
    state = state.copyWith(
      isSelectionMode: false,
      selectedTrackIds: {},
    );
  }

  Future<void> deleteSelectedTracks() async {
    final idsToDelete = state.selectedTrackIds.toList();
    if (idsToDelete.isEmpty) return;
    final tracksValue = state.tracks.asData?.value;
    if (tracksValue == null) return;

    final repo = ref.read(trackRepositoryProvider);
    for (final trackId in idsToDelete) {
      try {
        final track = tracksValue.firstWhere((t) => t.id == trackId);
        final file = File(track.dataUrl);
        if (file.existsSync()) {
          file.deleteSync();
        }
        await repo.deleteTrack(trackId);
      } catch (e) {
        // Ignore errors for individual tracks
      }
    }
    clearSelection();
    await loadLocalSongs();
  }

  void _applyFiltersAndSort() {
    List<Track> filtered = _rawTracks;

    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered.where((t) => 
        t.title.toLowerCase().contains(q) || 
        t.artist.toLowerCase().contains(q)
      ).toList();
    }

    filtered.sort((a, b) {
      int compare;
      switch (state.sortOption) {
        case TrackSortOption.title:
          compare = a.title.compareTo(b.title);
          break;
        case TrackSortOption.artist:
          compare = a.artist.compareTo(b.artist);
          break;
        case TrackSortOption.duration:
          compare = a.durationMs.compareTo(b.durationMs);
          break;
        case TrackSortOption.dateAdded:
          // Local tracks via on_audio_query don't natively map dateAdded yet in our Track model properly if year is used
          // Let's fallback to duration if we don't have it, or id. 
          // Actually, our local source doesn't expose dateAdded in Track model directly right now,
          // so we compare ID as a fallback (which is URI).
          compare = a.id.compareTo(b.id);
          break;
        case TrackSortOption.recentlyPlayed:
          compare = a.id.compareTo(b.id); // Placeholder for local only
          break;
      }
      return state.ascending ? compare : -compare;
    });

    state = state.copyWith(tracks: AsyncValue.data(filtered));
  }
}
