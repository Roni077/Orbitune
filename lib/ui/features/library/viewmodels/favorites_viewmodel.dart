import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/repositories/playlist_repository.dart';

final favoritesViewModelProvider = NotifierProvider<FavoritesViewModel, List<String>>(() {
  return FavoritesViewModel();
});

class FavoritesViewModel extends Notifier<List<String>> {
  String? _favoritesPlaylistId;

  @override
  List<String> build() {
    _initFavorites();
    return [];
  }

  Future<void> _initFavorites() async {
    final repo = ref.read(playlistRepositoryProvider);
    final result = await repo.getAllPlaylists();
    
    result.match(
      (failure) {},
      (playlists) async {
        try {
          final favPlaylist = playlists.firstWhere((p) => p.isFavoritePlaylist);
          _favoritesPlaylistId = favPlaylist.id;
          state = favPlaylist.trackIds;
        } catch (_) {
          // Create the favorites playlist
          final createResult = await repo.createPlaylist('Liked Songs', isFavoritePlaylist: true);
          createResult.match(
            (failure) {},
            (playlist) async {
              _favoritesPlaylistId = playlist.id;
              state = [];
            }
          );
        }
      }
    );
  }

  bool isFavorite(String trackId) {
    return state.contains(trackId);
  }

  Future<void> toggleFavorite(Track track) async {
    if (_favoritesPlaylistId == null) return;
    final repo = ref.read(playlistRepositoryProvider);
    
    if (isFavorite(track.id)) {
      await repo.removeTrackFromPlaylist(_favoritesPlaylistId!, track.id);
      state = state.where((id) => id != track.id).toList();
    } else {
      await repo.addTrackToPlaylist(_favoritesPlaylistId!, track);
      state = [...state, track.id];
    }
  }
}
