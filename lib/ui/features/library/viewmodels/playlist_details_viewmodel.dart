import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/playlist.dart';
import '../../../../domain/repositories/track_repository.dart';
import '../../../../domain/repositories/playlist_repository.dart';

final playlistDetailsViewModelProvider = AsyncNotifierProvider.family<PlaylistDetailsViewModel, List<Track>, Playlist>(PlaylistDetailsViewModel.new);

class PlaylistDetailsViewModel extends AsyncNotifier<List<Track>> {
  final Playlist playlistArg;
  late Playlist _playlist; // mutable so we can update the copy locally

  PlaylistDetailsViewModel(this.playlistArg);

  @override
  FutureOr<List<Track>> build() async {
    _playlist = playlistArg;
    return _fetchTracks();
  }

  Future<List<Track>> _fetchTracks() async {
    final trackRepo = ref.read(trackRepositoryProvider);
    final result = await trackRepo.getLocalTracks();

    return result.match(
      (failure) => throw Exception(failure.message),
      (allTracks) {
        // Find tracks that belong to this playlist and order them by the playlist's trackIds list
        final List<Track> playlistTracks = [];
        for (final id in _playlist.trackIds) {
          try {
            final track = allTracks.firstWhere((t) => t.id == id);
            playlistTracks.add(track);
          } catch (_) {}
        }
        return playlistTracks;
      },
    );
  }

  Future<void> _loadTracks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchTracks());
  }

  Future<void> removeTrack(String trackId) async {
    if (_playlist.isFavoritePlaylist) {
      // Favorite playlist is managed by favoritesViewModel, but we can't do it here easily.
      // So this method won't be called for favorites playlist directly.
      return;
    }
    final playlistRepo = ref.read(playlistRepositoryProvider);
    final result = await playlistRepo.removeTrackFromPlaylist(_playlist.id, trackId);
    if (result.isRight()) {
      final updatedTrackIds = _playlist.trackIds.where((id) => id != trackId).toList();
      _playlist = _playlist.copyWith(trackIds: updatedTrackIds);
      _loadTracks(); // Refresh
    }
  }

  Future<void> reorderTracks(int oldIndex, int newIndex) async {
    if (_playlist.isFavoritePlaylist) return;
    
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final updatedTrackIds = List<String>.from(_playlist.trackIds);
    final trackId = updatedTrackIds.removeAt(oldIndex);
    updatedTrackIds.insert(newIndex, trackId);

    // Update local state optimistically
    _playlist = _playlist.copyWith(trackIds: updatedTrackIds);
    // Reload state to reflect immediately
    state.whenData((tracks) {
      final updatedTracks = List<Track>.from(tracks);
      final track = updatedTracks.removeAt(oldIndex);
      updatedTracks.insert(newIndex, track);
      state = AsyncValue.data(updatedTracks);
    });

    // Save to DB
    final playlistRepo = ref.read(playlistRepositoryProvider);
    await playlistRepo.reorderTracks(_playlist.id, updatedTrackIds);
  }
}
